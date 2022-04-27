# Système Bancaire
Système bancaire qui permet aux joueurs d'ajouter, de retirer ou de transférer de l'argent de leurs comptes personnels et communs.

Ce système bancaire a été réalisé entièrement (maquette, front-end, lua) par <a href="https://github.com/s1nyx">Sinyx</a> pour le projet Starling City, cependant nous n'utilisons plus le script, j'ai donc décidé de mettre ce script sur github (avec l'accord du développeur bien évidemment)

Compatible avec :
 - ESX Legacy
 - ESX V1 (y compris les sous versions)


Fonctionnalités :
- Système de comptes communs (maximum 3)
- Système de cache (pour éviter trop de requêtes sql)
- Historique des achats
- Système de mot de passe pour se connecter à son compte bancaire
 
 ⚠️ Attention, ce script remplace complétement le système **bancaire** de ESX, il faudra donc adapter certaines choses afin d'adapté vos scripts au système bancaire.
 
 Pour adapté vos scripts aller voir comment utiliser les <a href="exports.md">Exports</a> (côté serveur)

<h1>Historique Achats</h1>

 Pour chaque paiement, vous avez un historique, par exemple lorsque vous allez retirer de l'argent à un ATM vous allez voir dans votre historique que vous avez retirer de l'argent à un ATM (avec une petite icône), dans la config vous devez rajouter votre "service" (dans la table servicesType), puis lorsque vous allez utiliser un export pour retirer ou ajouté de l'argent à un joueur vous allez mettre l'id (dans quel ordre est votre service), si on prend l'Auto-école par exemple, qui est dans la <a href="src/config.lua">config</a> l'id du service serait 7 (en Lua une table commence toujours à partir de 1), puis lorsque vous allez utiliser l'export, le 3e argument après le montant. Sera votre id à mettre.
 

<h1>Salaire ESX</h1>

Pour le système de salaire de ESX, le système de banque a **besoin** de es_extended cependant pour utiliser le système de banque sur les salaires, il faut qu'il soit start **avant** es_extended

<a href="https://gist.github.com/TheSpaceGamerV2/05eab8f2f73844273973779720b4a814">Adaptation Salaire Système de banque</a> 

Voici un exemple de start cfg
```
ensure mysql-async
ensure banking-system
ensure es_extended
```

⚠️ Ne changez pas le nom de la ressource sinon l'interface visuelle (NUI) ne fonctionnera plus.