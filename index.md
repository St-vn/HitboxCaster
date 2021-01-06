# HitboxCaster

### Written by St_vn#3931, St_vnC(Roblox)
### Version 2.4, 2/1/2021


HitboxCaster is an **open sourced raycast based hitbox module** that is **simple to use** and is **performance friendly** meant to be **used for melee hitboxes**. First of all, I decided to use raycast because it is the lightest hitbox method, even though you could cast a lot of rays every second, it would still be more performant `BasePart`'s Touched event. Region3's problem is that it requires you to check every part in a **large 3D box** so **Region3 would be more effective for explosive or AOE based hitboxes**.

The reason being is that **Raycast's intersection** math is less **heavy** than Touched's **collision detection math**. The methods that I used to make my module could potentially be alien to those who will use it but they still remain simple and effective. The only **functions** you need to know are the **constructor functions, the casting ones and the deconstructor.**


## How things are done

The constructor function requires the part that would have attachments in it, you could alternatively feed an array of offset vectors if you don't like to use attachments. It would internally loop through the given part's **children** and add the qualified(having the correct name) attachments' `Position` property in an array the similarly to the alternate way. Then it will create an object that inherits the `Hitbox` class methods.

One of the methods that the `Hitbox` has is to start casting rays with a **given callback and filter**. The callback would be the function that would get called when the hitbox hits a target. The filter is used to **blacklist unwanted groups of parts** and would create one internally if not specified. The filter **automatically adds** the `Part` to the filter list so ther wont be any need to add it. After all of that is done, it will **append the hitbox object** in an array of "active" hitboxes.

**Every frame**, the code will iterate through each **hitbox and cast rays from each offset vector/attachment position if the Part has moved**. If the rays pick something up, then it would check if the Part **has an ancestor that is a model** and then check if said model **has a humanoid child**. If all **prerequisites** were met, then it would call the **callback and append the Part in a secondary filter** list that is used to **filter parts** to make sure they don't get **hit twice**.

A hitbox has a function to **stop casting rays** to **save resources**. It will essentially **remove both its primary and secondary filter**, its **callback** and **anything else** that was made internally necessary to casting rays.

The deconstructor function is a function inherited from the hitbox class. It will **first call the method that stops casting**, so there wont be a need to call it manually **before destruction** of the hitbox. Then it will **remove everything from the hitbox** and let it get **garbage collected**.

**For more info on how things are done, I suggest you take a look at the source code yourself and the API as well.**


## Additional info

I've decided to make this module to be a **shorter version of Swordphin's Raycast Hitbox**. My first attempt was a **disaster** and I've learned from that which got me to where I currently am with this module. A lot of features were **inspired** from their module but were made into a much more **compact singular module**.


## Other kinds of hitboxes

**I don't plan** to open source any other kind of hitbox modules due to the reason of them being **tailored for my game(s)** only. It will likely be a better idea to make a **projectile module** of your own made for your game instead of using **general use ones**. For **splash effect and AOE** based hitboxes, I would suggest iterating through **candidates** that could potentially get hit and **compare the distance**, in other words a **linear search algorithm**. It is a better idea to loop through those who are **within a certain vicinity** by using **chunks** and such stuff to use **less resources**.


[HitboxCaster API](https://github.com/St-vn/HitboxCaster/)

[HitboxCaster src code](https://github.com/St-vn/HitboxCaster/)
