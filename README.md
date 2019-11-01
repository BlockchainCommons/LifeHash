# LifeHash

A method of hash visualization based on Conway’s Game of Life that creates beautiful icons that are deterministic, yet distinct and unique given the input data.

The basic concept is to take a SHA256 hash of the input data (which can be any data including another hash) and then use the 256-bit digest as a 16x16 pixel "seed" for running the cellular automata known as [Conway’s Game of Life](https://en.wikipedia.org/wiki/Conway's_Game_of_Life).

After the pattern becomes stable (or begins repeating) the resulting history is used to compile a grayscale image of all the states from the first to last generation. Using Game of Life provides visual structure to the resulting image, even though it was seeded with entropy.

Some bits of the initial hash are then used to deterministically apply symmetry and color to the icon to add beauty and quick recognizability.

![Samples of LifeHash](Art/Samples-0.jpg?raw=true "Samples 0") ![Samples of LifeHash](Art/Samples-856.jpg?raw=true "Samples 856")

![Samples of LifeHash](Art/Sample-88.jpg?raw=true "Sample 88") ![Samples of LifeHash](Art/Sample-229.jpg?raw=true "Sample 229")

![Samples of LifeHash](Art/Sample-526.jpg?raw=true "Sample 526") ![Samples of LifeHash](Art/Sample-799.jpg?raw=true "Sample 799")

An example from the Mathematica implementation.

![Samples of LifeHash](Art/Samples-0-Mathematica.jpg?raw=true "Samples 0") 

## Platforms

LifeHash is available through Swift Package Manager and as a Mathematica notebook.

## Author

Wolf McNally, wolf@wolfmcnally.com

## License

LifeHash is available under the MIT license. See the LICENSE file for more info.
