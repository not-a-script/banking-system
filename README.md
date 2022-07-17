# Banking System
A banking system that allows players to add, withdraw or transfer money from their personal and common accounts.

🇫🇷 <a href="https://github.com/idev-co/banking-system/tree/esx-french">Here</a>

This banking system was made entirely (mockup, front-end, lua) by <a href="https://github.com/s1nyx">Sinyx</a> for the Starling City project, since we don't use the script anymore i decided to put this script on github (with the developer's consent of course)

Compatible with :
 - ESX Legacy
 - ESX V1 (including sub versions)

<!> IMPORTANT: The resource needs to be named banked-system otherwise it won't work.

Features :
- Common account system (maximum 3)
- Money transfer
- Cache system (to avoid too many sql requests)
- Purchase history
- Password system to connect to your bank account
 
 ⚠️ Becareful, this script replaces completely the **banking** system of ESX, it will be necessary to adapt some things in order to adapt your scripts to the banking system.
 
 To adapt your scripts go see how to use <a href="exports.md">Exports</a> (server side)

<h1>Purchase History</h1>

 For each payment, you have a history, for example when you withdraw money from an ATM you will see in your history that you have withdrawn money from an ATM (with a small icon), in the <a href="src/config.lua">configuration</a> you must add your "service" (in the table servicesType), then when you are going to use an export to withdraw or add money to a player you will put the id (in which order is your service), if we take the driving school for example, which is in the config, the id of the service would be 7 (in Lua a table always starts from 1), then when you are going to use the export, the 3rd argument after the amount will be your id to put.

<h1>ESX Salary [Jobs]</h1>

For the ESX salary system, the bank system needs es_extended however to use the bank system on salaries, it must be started **before** es_extended

<a href="https://gist.github.com/TheSpaceGamerV2/05eab8f2f73844273973779720b4a814">How to adapt salary ?</a> 

Here is an example of how start the cfg
```
ensure mysql-async
ensure banking-system
ensure es_extended
```

⚠️ Do not change the name of the resource or the visual interface (NUI) will not work.

You can have support on our <a href="https://discord.gg/8ecXhFXqR4">Discord</a> (FR/ENG)

![Capture d’écran 2022-04-27 223321](https://user-images.githubusercontent.com/40030799/165626282-2604065e-e66d-4fbd-bdd3-f316ddd47549.png)
![Capture d’écran 2022-04-27 223344](https://user-images.githubusercontent.com/40030799/165626322-f46cef4f-05d6-4ca8-8583-96adbd92caf8.png)
![Capture d’écran 2022-04-27 223359](https://user-images.githubusercontent.com/40030799/165626342-fdf99314-50ae-4a44-a631-a3b2d880d9d1.png)



