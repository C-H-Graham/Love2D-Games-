# LOVE2D Projects

In this repository are two simple games created using the Love2D game engine, a game engine based around the LUA language.

For more information on the Love2D Engine, you can visit [this link!](https://love2d.org/)

The projects are based on curriculum taken on by Colton Ogden and the class of CS50G over at Harvard

**Running the Games**
1. Install Love2D, you can get it at the link above
2. Open your shell or command prompt and enter one of the following commands:
    - Windows: `"C:\Program Files\LOVE\love.exe" "C:\games\mygame"`
    - Linux: `love /home/path/to/gamedir/`
    - OSX: `open -n -a love "~/path/to/mygame"`
**Note:** navigate to the last breakoutfolder for the current version of the project. The other folders are previous iterations with less features or working code.

For more info on getting started, you can go [here](https://love2d.org/wiki/Getting_Started)


## Match 3

If you like Bejeweled, surely you will like this amateurs quick derivative right?! Well if you are still interested go ahead and try out of the game. 

Gameplay is simple. Navigate the Tile Board with your arrow keys, hit enter to select a tile and then select another adjacent tile to swap their positions. The game will swap their positions and check if there are any matching tiles (in horizontal or vertical lines) have been formed. Additionally, matching can be done by color, or my the symbol after level 7. 

The matching algorithm is brute force, but I would love to go back one day and refactor with a better solution. I would also like to go back with a solution of being able to insert a pattern into a non-matching board to at ensure at least 1 match per level.

Known Issues:
- The actual swapping animation can break if the selection is input in fast enough. 

## Breakout

This classic game is simple. Keep the ball from falling and break all the blocks above you! The game is admittedly janky, but this was my first project and overall I am happy with how it turned out.

Known Issues:
- Having too many balls on screen through the multiball powerup increases chances of the balls getting stuck on collision, particularly the paddle. This is likely to do with looking through each ball to update position
- Minor issue here, but the points for getting powerups were left low for testing purposes.
