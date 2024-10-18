powershell.exe -command "Invoke-WebRequest  -UseBasicParsing -Uri 'https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe' -OutFile './python-amd64.exe'"
.\python-amd64.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
del "./python-amd64.exe"