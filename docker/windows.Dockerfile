# escape=`
FROM mcr.microsoft.com/windows/server:ltsc2025
ARG VERSION
SHELL ["powershell", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN if (-not $env:VERSION) { throw 'build arg VERSION is required, e.g. --build-arg VERSION=1.1.3' }; `
    Invoke-WebRequest https://aka.ms/vs/17/release/vc_redist.x64.exe -OutFile C:\vc_redist.exe; `
    $redist = Start-Process C:\vc_redist.exe -ArgumentList '/install', '/quiet', '/norestart' -Wait -PassThru; `
    if ($redist.ExitCode -notin 0, 3010) { throw ('vc_redist failed with exit code {0}' -f $redist.ExitCode) }; `
    Remove-Item C:\vc_redist.exe; `
    Invoke-WebRequest ('https://www.ark-vcs.com/static/versions/Ark-Vcs_{0}_win.zip' -f $env:VERSION.Replace('.', '_')) -OutFile C:\ark.zip; `
    Expand-Archive C:\ark.zip C:\ark-unpacked; `
    New-Item -ItemType Directory C:\ark, C:\data | Out-Null; `
    Move-Item C:\ark-unpacked\*\ark.exe C:\ark\ark.exe; `
    Remove-Item -Recurse C:\ark.zip, C:\ark-unpacked
EXPOSE 9000
ENTRYPOINT ["C:\\ark\\ark.exe"]
CMD ["server", "-path", "C:\\data"]
