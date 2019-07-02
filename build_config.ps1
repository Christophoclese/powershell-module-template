$BUILD_CONFIG = @{
    # This controls which Repository Publish-Module.ps1 builds to
    # It also affects which Repository the published moduled will use to check for updates
    PSRepositoryName = 'Operations'

    # This tells Test & Build scripts what to name the module
    ModuleName = 'ModuleTemplate'
}
