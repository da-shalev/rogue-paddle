# unnamed-game-1

A [LÖVE](https://love2d.org/) game developed for a college’s capstone project

<br>

## Development

### Launch the game

In this repositories root directory, you can run the game directly with LÖVE:

```sh
love ./src
```

> **Note**: You need to have [LÖVE](https://love2d.org/) installed on your
> system to run the game this way.


### Running with Nix

If you are using **Nix flakes**, this project defines an app target so you can launch the game without installing LÖVE manually.

##### In this repository:

```sh
nix run
```

##### From the current git commit (remote):

```sh
nix run "git+ssh://git@github.com/da-shalev/unnamed_game_1.git"
```

### VS Code Extensions

For development, use the following extensions:

- [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua)
- [StyLua](https://marketplace.visualstudio.com/items?itemName=JohnnyMorganz.stylua)


### Attribution:

* [https://leo-red.itch.io/lucid-icon-pack](https://leo-red.itch.io/lucid-icon-pack) (icons)
