:warning: Je vais utiliser xPlayer.getIdentifier(), mais vous n'êtes pas obligé du moment ou vous avez l'identifier du joueur c'est bon
 

Retirer de l'argent 
  ```lua
 exports["stl_bankingsystem"]:RemoveMoney(xPlayer.getIdentifier(), 50000, 1, function(success)
    if success then
        print("Il a bien + ou = à 50 000$ sur son compe perso donc il retire")
    else
        print("Il a pas assez d'argent donc il retire pas")
    end
end, false)
-- 50000 correspond au montant à retirer
-- 1 correspond à l'id de l'achat (j'explique ça plus bas)
-- le false après le end précise que vous ne voulez pas retirer l'argent de force
```

Retirer de l'argent (de force, donc même si il a moins que le montant demander on retire)
```lua
exports["stl_bankingsystem"]:RemoveMoney(xPlayer.getIdentifier(), 50000, 1, function(success)
    if success then
        print("Même si il a moins de 50 000$ on retire")
    else
        print("Son compte a pas été trouvé")
    end
end, true)
-- 50000 correspond au montant à retirer
-- 1 correspond à l'id de l'achat (j'explique ça plus bas)
-- le true après le end précise que vous voulez retirer l'argent de force
```

Ajouter de l'argent 
```lua
 exports["stl_bankingsystem"]:AddMoney(xPlayer.getIdentifier(), 50000, 1, function(success)
    if success then
        print("Il a bien + ou = à 50 000$ sur lui donc il ajoute")
    else
        print("Il a pas assez de money donc il ajoute pas")
    end
end, false)
-- 50000 correspond au montant à retirer
-- 1 correspond à l'id de l'achat (j'explique ça plus bas)
-- le false après le end précise que vous ne voulez pas ajouter l'argent de force
```

Ajouter de l'argent (de force)
```lua
exports["stl_bankingsystem"]:AddMoney(xPlayer.getIdentifier(), 50000, 1, function(success)
    if success then
        print("Même si il a moins de 50 000$ sur lui on dépose")
    else
        print("Son compte a pas été trouvé")
    end
end, true)
-- 50000 correspond au montant à retirer
-- 1 correspond à l'id de l'achat (j'explique ça plus bas)
-- le true après le end précise que vous voulez ajouter l'argent de force
```

Voir l'argent sur le compte d'un joueur
```lua
local accountBank = exports['stl_bankingsystem']:GetBankMoney(xPlayer.getIdentifier())
print(accountBank) -- va vous retourner l'argent dans son compte bancaire
```
Rafraichir les données d'un joueur (donc le retirer du cache et forcé le script à faire une requête sql)
```lua
RemoveFromCache(xPlayer.getIdentifier())
