:warning: I'll use xPlayer.getIdentifier(), but you don't have to, as long as you have the player's identifier it's fine
 

Remove money
  ```lua
 exports["stl_bankingsystem"]:RemoveMoney(xPlayer.getIdentifier(), 50000, 1, function(success)
    if success then
        print("He has + or = $50,000 on his personal account so we remove the money")
    else
        print("He doesn't have enough money so we doesn't remove the money")
    end
end, false)
-- 50000 is the amount to be removed
-- 1 corresponds to the id of the purchase (I explain this in the readme)
-- the false after the end specifies that you do not want to remove the money by force
```

Remove money (by force, so even if he has less than the amount requested we remove)
```lua
exports["stl_bankingsystem"]:RemoveMoney(xPlayer.getIdentifier(), 50000, 1, function(success)
    if success then
        print("Even if he has less than 50 000$ we remove the money")
    else
        print("His account has not been found")
    end
end, true)
-- 50000 is the amount to be removed
-- 1 corresponds to the id of the purchase (I explain this in the readme)
-- the true after the end specifies that you want to remove the money by force
```

Add money 
```lua
 exports["stl_bankingsystem"]:AddMoney(xPlayer.getIdentifier(), 50000, 1, function(success)
    if success then
        print("He has + or = $50,000 on him so we add the money")
    else
        print("He doesn't have enough money so we doesn't add the money")
    end
end, false)
-- 50000 is the amount to be removed
-- 1 corresponds to the id of the purchase (I explain this in the readme)
-- the false after the end specifies that you do not want to add the money by force
```

Add money (by force)
```lua
exports["stl_bankingsystem"]:AddMoney(xPlayer.getIdentifier(), 50000, 1, function(success)
    if success then
        print("Even if he has less than 50 000$ on his bank account we add the money")
    else
        print("His account has not been found")
    end
end, true)
-- 50000 is the amount to be removed
-- 1 corresponds to the id of the purchase (I explain this in the readme)
-- the true after the end specifies that you want to add the money by force
```

See the money in a player's account
```lua
local accountBank = exports['stl_bankingsystem']:GetBankMoney(xPlayer.getIdentifier())
print(accountBank) -- will return the money in his bank account
```
Refresh a player's data (i.e. remove it from the cache and force the script to make an sql query)
```lua
RemoveFromCache(xPlayer.getIdentifier())
```
