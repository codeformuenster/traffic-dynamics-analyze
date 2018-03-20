# traffic-dynamics-analyze
Statistische Analysen Münsteraner Verkehrszähldaten

More information coming soon.

The following text is not up-to-date due to repository restructuring (but it's still here to not get lost) -- we are working on it, stay tuned!

## Computing all Bayesian regression models using Docker

In the file `src/03_Bayesian_glms.R` there are some Bayesian regression models specified. Those can be computed with the help of the R package [brms](https://cran.r-project.org/package=brms). Since the computation takes some time and you might also not like to fiddle around with installing all the prerequisites, we created a docker image that you could run on any docker capable computer. After you've run the image you should have some models files saved to your disk in the `results` directory.

This is how to start the docker image.
First, build it and give it a name (here `traffic-dynamics-analze-local`):

```
sudo docker build -t traffic-dynamics-analyze-local .
```

Then run the docker image and tell it to run the `src/03_Bayesian_glms.R` file:

```
sudo docker run --rm -v $(pwd)/results/:/srv/shiny-server/results --privileged traffic-dynamics-analyze-local
```

If you are running a linux distribution with enabled SELinux support (like Fedora) and get a permission error, you could try to add the `--privileged` flag to the docker command. Otherwise, you might disable SELinux temporarily with `sudo setenforce 0` (check with `getenforce`). Don't forget to enable it back again afterwards with `sudo setenforce 1`.

If all went fine, you should have some `.RData` files (that contain `brms` model fits) after the docker run in the `results` folder. It will take some time, though!


## Rechtliches

### Quelltext

Copyright © 2017-2018 Thorben Jensen, Thomas Kluth

#### Deutsch 

Dieses Programm ist Freie Software: Sie können es unter den Bedingungen
der GNU General Public License, wie von der Free Software Foundation,
Version 3 der Lizenz oder (nach Ihrer Wahl) jeder neueren
veröffentlichten Version, weiterverbreiten und/oder modifizieren.

Dieses Programm wird in der Hoffnung, dass es nützlich sein wird, aber
OHNE JEDE GEWÄHRLEISTUNG, bereitgestellt; sogar ohne die implizite
Gewährleistung der MARKTFÄHIGKEIT oder EIGNUNG FÜR EINEN BESTIMMTEN ZWECK.
Siehe die GNU General Public License für weitere Details.

Sie sollten [eine Kopie der GNU General Public License zusammen mit diesem
Programm erhalten haben](COPYING). Wenn nicht, siehe <http://www.gnu.org/licenses/>.

#### Englisch

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have [received a copy of the GNU General Public License
along with this program](COPYING). If not, see <http://www.gnu.org/licenses/>.

### Daten

Datenquelle: Stadt Münster

[Datenlizenz Deutschland – Namensnennung – Version 2.0](http://www.govdata.de/dl-de/by-2-0) (oder [diese pdf-Datei](doc/Stadt_MS_OpenData_Datenlizenz_Deutschland.pdf))

