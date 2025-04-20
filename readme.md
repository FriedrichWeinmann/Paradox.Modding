# Welcome to the Paradox Modding Tools Project

One of the fun aspects to the Paradox Studios games - such as Stellaris, Hearts of Iron, Europa Universalis or Imperator: Rome - is how extensible they are.
The game is basically its own mod, and the community has provided many, many more.

That's fun and well, so now we try to build our own mod and it works quite well!
Until, that is, we screw something up and our game won't load our contents.
Going back to a previous state is easy ... if you have put your mod into source control.
But your game doesn't look into the place where you put your github repositories ...

Also, maybe we want to automate a few things - for example to copy & modify/override existing game files, which we want to redo after each game update (and who wants to do that manually each time?).

So, there is a need for automation, and this is where my project here comes in:
Its core purpose is to ...

1. Copy each of your mods from source control into a temporary staging folder
2. Apply any automation you provide
3. Clean up the copy and send it to where your game expects mods

Along the way, it provides some conveniences to help automation tasks, and offer tools to help accelerate you writing your own stuff (assuming you do PowerShell).

> Don't worry: You do not need to know programming in general or PowerShell in particular to use this

## Setting up the tools

> Installing PowerShell

First of all, you need to install the tools on the computer you want to run this on.
This is a PowerShell based toolset, so you need PowerShell. If you're on Windows, you are already covered, if you are on Linux or MacOS, you will need to install it first:

+ [Install on Linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux)
+ [Install on MaxOS](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos)

> Execution Policy

On Windows, you may need to disable [Execution Policy](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies):

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

> The Modding Tools

Once you have PowerShell all ready to go, open a PowerShell console and run this:

```powershell
Install-Module Paradox.Modding -Scope Currentuser
```

With that you should be good to go.

## Set up the mod building

With the tools ready to roll, it is now time to prepare for automation!
What we need to do is create a build script and place it wherever seems convenient. As a suggestion, lets place it in the same folder where you put the individual mod directories:

```text
├───Mod1
├───Mod2
├───Mod3
└───build.ps1
```

Here are a few example definitions of the `build.ps1` to help get you started:

+ [Hearts of Iron IV](docs/build-hoi4.ps1)
+ [Imperator: Rome](docs/build-imperator.ps1)
+ [Stellaris](docs/build-stellaris.ps1)

The name of your build script does not matter* (PowerShell expects the file extension ".ps1" though).

That's it, we are now ready to roll.

## Build your mods

To run the entire thing, simply execute this line in a PowerShell console (substitute the path as needed):

```powershell
& C:\code\mods\Stellaris\build.ps1
```

And that's it :)

## Not The Defaults

As mentioned, you can place the file wherever you want, but the examples assume you put it in the folder as shown above.
If you _do_ change the path however ...

+ You can update the path as provided to the `-Path` parameter on `Build-PdxMod` however you want.
+ By default it will pick up all subfolders in the directory specified to `-Path`. If you want to be selective, also provide the `-Name` parameter.

Example for Stellaris with the build script _inside_ the mod folder of Mod1:

```powershell
Build-PdxMod -Path "$PSScriptRoot\.." -Name Mod1 -Game Stellaris -Tags Stellaris
```

This will only build the current mod (assuming it is named "Mod1").

> WARNING! WARNING!! WARNING!!!
>
> If you place the build script _inside_ your mod folder at the root level, **IT MUST NOT BE NAMED "build.ps1"!**
> You will create an infinite loop of recursion if you do, red error messages shall be your reward.
> See below for more details.

Other than that, you can mess around with the content of the build script as much as you care, if you know your PowerShell or can live with error messages.

## What changes for my mods?

Nothing.

Or at least, you do not _have_ to change the way you write mods.

But:
You _can_ now "benefit" from new capabilities brought by game-specific modules you installed as part of this setup.
I'm a bit cagey about _benefit_, because quite a bit inside that is intended for people comfortable with PowerShell (or at least programming in general), so your mileage may vary.

Here are the game-specific docs:

+ [Stellaris](https://github.com/FriedrichWeinmann/Paradox.Modding.Stellaris)
+ [Hearts of Iron IV](https://github.com/FriedrichWeinmann/Paradox.Modding.HOI4)

## My Own Automation?

You want to integrate your own automation in this?
Sure, it is setup for just that.

If you are writing PowerShell already, that's easy, if you prefer another language (such as Python), it's still doable.

Whenever we run `Build-PdxMod` ...

+ we first copy the mod into a temporary folder.
+ Then we apply any magic implemented by module extensions (see previous section and the game-specific links).
+ Then we look for a `build.ps1` powershell script file in the root folder of the mod and run that. _This is the reason, that if you place the overall build/publish script discussed here in the mod root, you_ must _not name it "build.ps1", as it will otherwise keep calling itself!_
+ Then we delete undesired files, based on their extension
+ Then we move the result to the destination path (usually, where the Game expects mods)

So, if you want to add your own automation, you have two options:

### 1.: Create mod-specific `build.ps1`

The simpler method, and also the best way to switch to another language.
Anything you write in `build.ps1` is executed, so you can freely add your own statements, only your coding skills are the limit.

Notes:

+ The `$PSScriptRoot` variable points at the root folder of your mod.
+ Most game modules provide a command to try and find the game root, in case you want to copy over some of the original files at build time. E.g.: `Get-PdsGameDirectory` will get you the Stellaris root folder.

### Switch to another language

Now, assuming you want to do your own build automation in your preferred language - and that language happens to not be PowerShell - there is a simple enough way to do that.
For the purpose of our example we will be using Python.

You are responsible for installing all the tools needed yourself (sorry).

But lets say you have placed all your Python code in `build.py` at the root of your mod.
Then place a `build.ps1` in the same folder [with this content](docs/build-with-python.ps1).

With that, `Build-PdxMod` calls `build.ps1`, which will start Python to run `build.py`.

### 2.: Add a Build Extension

Not for the faint of heart, requires PowerShell knowledge, but quite Powerful.
To get started with that, run this:

```powershell
Get-Help Register-PdxBuildExtension -Detailed
```

Extensions basically allow you to integrate native automation plugins that are applied to all mods without having to define local build.ps1 files and do it in there.
It is how the game-specific modules integrate their custom config file formats for individual components.

Example from the Stellaris module:

+ [Registering the Extension](https://github.com/FriedrichWeinmann/Paradox.Modding.Stellaris/blob/master/Paradox.Modding.Stellaris/internal/scripts/buildextensions.ps1)
+ [Implementing The Building Config format](https://github.com/FriedrichWeinmann/Paradox.Modding.Stellaris/blob/master/Paradox.Modding.Stellaris/functions/ConvertTo-PdsBuilding.ps1)
