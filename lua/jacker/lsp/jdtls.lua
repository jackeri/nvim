-- Java (jdtls) LSP setup: locates installed JDKs, finds project formatter
-- config (style.xml / Eclipse style) and configures jdtls accordingly.

local M = {}

local function find_format_file(cwd, file)
  local cfgPath = cwd .. '/' .. file
  if not vim.uv.fs_stat(cfgPath) then
    cfgPath = cwd .. '/style/' .. file
    if not vim.uv.fs_stat(cfgPath) then
      cfgPath = nil
    end
  end
  return cfgPath
end

-- JDTLS persists its project model/index in a per-project "workspace"
-- directory (the `-data` arg). That cache is only compatible with the
-- jdtls build that created it and can corrupt itself if the process is
-- killed mid-write, so we (a) version the workspace path by the installed
-- jdtls version to avoid reusing an incompatible cache after a Mason
-- update, and (b) quarantine the workspace automatically if jdtls ever
-- exits abnormally, so a corrupted cache can't keep crashing it forever.
local function get_jdtls_version(mason_packages_path)
  local receipt_path = mason_packages_path .. '/jdtls/mason-receipt.json'
  local ok, lines = pcall(vim.fn.readfile, receipt_path)
  if not ok or not lines or #lines == 0 then
    return nil
  end
  local decode_ok, receipt = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not decode_ok or type(receipt) ~= 'table' then
    return nil
  end
  local id = receipt.source and receipt.source.raw and receipt.source.raw.id
  if type(id) == 'string' then
    return id:match '@(.+)$'
  end
  return nil
end

local function quarantine_workspace(workspace_folder, code)
  if not vim.uv.fs_stat(workspace_folder) then
    return
  end
  local backup = workspace_folder .. '.corrupted-' .. os.time()
  local renamed = os.rename(workspace_folder, backup)
  vim.schedule(function()
    if renamed then
      vim.notify(
        string.format(
          'jdtls exited abnormally (code %d). Its workspace cache was moved to %s so it can rebuild a fresh one. Reopen the Java buffer to restart it.',
          code,
          backup
        ),
        vim.log.levels.WARN
      )
    else
      vim.notify(
        string.format(
          'jdtls exited abnormally (code %d) and its workspace cache at %s may be corrupted. Delete it manually if problems persist.',
          code,
          workspace_folder
        ),
        vim.log.levels.WARN
      )
    end
  end)
end

local function parse_jdk_version(path)
  local jdk_rel = vim.fn.glob(path .. '/release')
  if vim.uv.fs_stat(jdk_rel) then
    local text = vim.fn.readfile(jdk_rel)
    for _, line in ipairs(text) do
      if line:match 'JAVA_VERSION' then
        local version_ok, jdk_version = pcall(tonumber, line:match '([0-9]+)%.?')
        if version_ok and type(jdk_version) == 'number' then
          return jdk_version
        end
      end
    end
  end
  return nil
end

function M.setup(mason_registry, capabilities)
  if not mason_registry.is_installed 'jdtls' then
    return
  end
  local settingsTable = nil

  -- Try to find a local style.xml file for JDTLS formatter
  local cwd = vim.fn.getcwd()
  local cfgPath = find_format_file(cwd, 'style.xml')
  local importOrderFile = find_format_file(cwd, 'style.importorder')

  if cfgPath then
    settingsTable = { url = cfgPath }
  else
    -- Check for Eclipse style configuration and set it up for JDTLS
    local eclipseStyleConfig = os.getenv 'ECLIPSE_STYLE_CONFIG'
    local eclipseStyleProfile = os.getenv 'ECLIPSE_STYLE_PROFILE'
    if eclipseStyleConfig and string.len(eclipseStyleConfig) > 0 and vim.uv.fs_stat(eclipseStyleConfig) then
      settingsTable = {
        url = eclipseStyleConfig,
        profile = eclipseStyleProfile,
      }
    end
  end

  if not settingsTable then
    return
  end

  local java_paths = {}

  if vim.fn.has 'macunix' == 1 then
    -- Scan both system-wide and per-user JVM install locations, since JDKs
    -- installed by IDEs/tools often only show up under the user's home dir.
    local home = os.getenv 'HOME'
    local vm_globs = { '/Library/Java/JavaVirtualMachines/*/Contents/Home' }
    if home and string.len(home) > 0 then
      table.insert(vm_globs, home .. '/Library/Java/JavaVirtualMachines/*/Contents/Home')
    end

    local highest_jvm = -1
    for _, vm_glob in ipairs(vm_globs) do
      local vms = vim.fn.expand(vm_glob)
      for jdk in vms:gmatch '[^\r\n]+' do
        local jdk_version = parse_jdk_version(jdk)

        if jdk_version then
          if jdk_version > highest_jvm then
            highest_jvm = jdk_version
          end
          table.insert(java_paths, {
            name = 'Java-' .. jdk_version,
            path = jdk,
          })
        end
      end
    end

    for _, jdk in ipairs(java_paths) do
      if jdk.name == 'Java-' .. highest_jvm then
        jdk.default = true
      end
    end
  else
    local java_home = os.getenv 'JAVA_HOME'
    if java_home and string.len(java_home) > 0 then
      local java_home_path = vim.fn.expand(java_home)
      if vim.uv.fs_stat(java_home_path) then
        table.insert(java_paths, {
          path = java_home_path,
          name = 'Java',
          default = true,
        })
      end
    end
  end

  -- Check if the JAVA_HOME is set and if it points to a valid JDK
  -- If not, set it to the highest version found
  -- This is a workaround for the JDTLS not being able to find the JDK
  local function check_and_set_jvm()
    local java_home = os.getenv 'JAVA_HOME'
    local java_version = nil
    if java_home and string.len(java_home) > 0 then
      java_version = parse_jdk_version(java_home)
    end

    -- The Mason-installed JDTLS build requires Java 25 or higher to boot
    -- (its OSGi framework declares osgi.ee=JavaSE;version=25); older JDKs
    -- cause it to exit immediately with code 13.
    if java_version and java_version >= 25 then
      return
    end

    for _, jdk in ipairs(java_paths) do
      local version_ok, jdk_version = pcall(tonumber, jdk.path:match '([0-9]+)%.?')
      if version_ok and type(jdk_version) == 'number' then
        if java_version == nil or jdk_version > java_version then
          java_version = jdk_version
          vim.uv.os_setenv('JAVA_HOME', jdk.path)
        end
      end
    end

    if java_version == nil or java_version < 25 then
      vim.notify('No valid JDK(version >= 25) found, please set JAVA_HOME', vim.log.levels.ERROR)
      return
    end
  end

  check_and_set_jvm()

  local importOrderTable = {
    'java',
    'jakarta',
    'javax',
    'com',
    'org',
  }
  if importOrderFile then
    local file = io.open(importOrderFile, 'r')
    local order = {}
    if file then
      for line in file:lines() do
        if line:sub(1, 1) == '#' then
          goto continue
        end
        local offset = line:find '='
        if not offset then
          goto continue
        end
        local key = line:sub(offset + 1):gsub('%s+', '')
        table.insert(order, key)
        ::continue::
      end
      file:close()
      importOrderTable = order
    end
  end

  local home = os.getenv 'HOME'
  local root_dir = vim.fs.dirname(vim.fs.find({ 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }, { upward = true })[1])
  local mason_packages = vim.fn.expand '$MASON/packages'
  local jdtls_version = get_jdtls_version(mason_packages)
  local workspace_folder = home .. '/.local/share/eclipse/' .. vim.fn.fnamemodify(root_dir, ':p:h:t') .. (jdtls_version and ('-' .. jdtls_version) or '')

  vim.lsp.config('jdtls', {
    capabilities = capabilities,

    on_exit = function(code, _, _)
      if code ~= 0 then
        quarantine_workspace(workspace_folder, code)
      end
    end,

    cmd = {
      mason_packages .. '/jdtls/bin/jdtls',
      '-data',
      workspace_folder,
      '--jvm-arg=-javaagent:' .. mason_packages .. '/jdtls/lombok.jar',
      '--jvm-arg=-Xmx1G',
      '--jvm-arg=-XX:+UseG1GC',
      '--jvm-arg=-XX:+UseStringDeduplication',
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
    },

    root_markers = { 'mvnw', 'gradlew', '.git', 'pom.xml', 'build.gradle' },

    -- ... all your other stuff
    settings = {
      java = {
        import = {
          gradle = {
            enabled = false,
          },
          maven = {
            enabled = false,
          },
        },
        format = {
          settings = settingsTable,
        },
        importOrder = importOrderTable,
        signatureHelp = { enabled = true },
        contentProvider = { preferred = 'fernflower' }, -- Use fernflower to decompile library code
        sources = {
          organizeImports = {
            starThreshold = 4,
            staticStarThreshold = 4,
          },
        },
        -- Specify any completion options
        completion = {
          useWildcard = true,
          wildcardTrigger = 4,
          favoriteStaticMembers = {
            'org.hamcrest.MatcherAssert.assertThat',
            'org.hamcrest.Matchers.*',
            'org.hamcrest.CoreMatchers.*',
            'org.junit.jupiter.api.Assertions.*',
            'java.util.Objects.requireNonNull',
            'java.util.Objects.requireNonNullElse',
            'org.mockito.Mockito.*',
          },
          filteredTypes = {
            'com.sun.*',
            'io.micrometer.shaded.*',
            'java.awt.*',
            'jdk.*',
            'sun.*',
          },
        },
        -- How code generation should act
        codeGeneration = {
          toString = {
            template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}',
          },
          hashCodeEquals = {
            useJava7Objects = true,
          },
          useBlocks = true,
        },
        eclipse = {
          downloadSources = true,
          -- jdtls = {
          --   vmargs = '-javaagent:/path/to/lombok.jar',
          -- },
        },
        maven = {
          downloadSources = true,
        },
        implementationsCodeLens = {
          enabled = true,
        },
        referencesCodeLens = {
          enabled = true,
        },
        -- configuration = {
        --   runtimes = java_paths,
        -- },
      },
    },
  })
end

return M
