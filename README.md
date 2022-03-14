# SysTeamHackaton

Een eenvoudige web-app + database ontwikkeld in .NET 6 en MSSQL 2019 t.b.v. de hackaton van het KOOP System Team. 
De web-app bevat drie pagina's;
- Default page: Toont de status en enkele metrieken van de container en de pod
- History metrics: Haalt het CPU en Memory verbruik van de container op uit de database en toont deze in een grafiek
- Monitor: Een pagina die periodiek aangeroepen dient te worden en het CPU en Memory verbruik op dat moment wegschrijft naar de database

Zowel de web-app als de database hebben als target platform linux-x64.

Installatie web-app
-------------------
1) Base image: mcr.microsoft.com/dotnet/aspnet:6.0
   (zie ook https://hub.docker.com/_/microsoft-dotnet-aspnet/)
2) Installeer de volgende linux packages:
   - sysstat
   - lsb-release
   - procps
3) Plaats de gehele inhoud van de directory WebApp in de linux omgeving
4) Start de web-app met het commando 'dotnet SysTeamHackatonWebApp.dll'
5) De website zou nu moeten draaien op poort 80
6) Schedule een job zodat iedere minuut de pagina /monitor van de web-app wordt aangeroepen
7) Om ook Pod informatie te kunnen tonen op de webpagina moeten er enkele omgevingsvariabelen worden gezet bij een deployment in een Kubernetes cluster:
   MY_NODE_NAME =  spec.nodeName
   MY_POD_NAME = metadata.name
   MY_POD_NAMESPACE = metadata.namespace
   MY_POD_IP = status.podIP
   MY_POD_SERVICE_ACCOUNT = spec.serviceAccountName
   (zie ook https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/)

Installatie database
--------------------
1) Base image: mcr.microsoft.com/mssql/server:2019-latest
   (zie ook https://hub.docker.com/_/microsoft-mssql-server)
2) Draai het sql script DbCreate.sql om de database, login en user aan te maken in MSSQL.
