/** Filename: rmprefix.cc
 * 
 * Description:
 *	Simple program that takes input from stdin and trims leading white space from each line.
 * 
 * Author: Adam Spilchen
*/

#include <iostream>
#include <string>
#include <cstdlib>
#include <locale>
#include <algorithm>

int main()
{
		std::string::iterator iter;

    for (std::string line; std::getline(std::cin, line);)
		{
				// Search for first none white space char.
				iter = std::find_if(line.begin(),
														line.end(),
														// lambda: returns bool
														[](char c) { return !std::isspace(c); } ); 

				// Erase all white space from start of line to first non whitespace char.
				line.erase(line.begin(), iter);

        std::cout << line << std::endl;
    }

	exit(EXIT_SUCCESS);
}
