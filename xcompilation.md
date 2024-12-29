---
title: "Laboratoire 1 : Installation de l'environnement de compilation croisée"
---

> **Note importante** : cette procédure n'est à réaliser **que si vous n'utilisez pas la machine virtuelle Fedora fournie** (par exemple que vous voulez utiliser votre propre installation Linux). Nous vous fournissons ici les instructions vous permettant d'installer la chaîne de compilation croisée sur tout environnement Linux, mais nous _n'offrons aucun support technique_ si vous choisissez cette option.

## 1. Installation de l'environnement de compilation croisée

Le Raspberry Pi possède un processeur dont l'architecture (ARM) diffère de celle de votre ordinateur (x86-64). Vous ne pouvez donc pas directement transférer un exécutable compilé sur votre ordinateur. Il faut plutôt utiliser un environnement de _compilation croisée_, qui permettra à votre ordinateur de générer des binaires compatibles avec l'architecture ARM du Raspberry Pi. Pour mettre en place cet environnement, nous devrons (dans l'ordre) :

1. Installer [Crosstool-NG](https://crosstool-ng.github.io/), un outil nous permettant de créer des chaînes de compilation croisée;
2. Configurer Crosstool-NG selon les spécificités du Raspberry Pi Zero;
3. Compiler et installer l'environnement de compilation croisée sur votre ordinateur;
4. Synchroniser les librairies et en-têtes depuis le Raspberry Pi Zero;
5. Préparer une configuration CMake pour la compilation croisée.

Notez que la compilation de cet environnement peut prendre un certain temps. Cette installation doit être faite *que vous utilisiez ou non la machine virtuelle fournie*.


### 1.1. Installation de Crosstool-NG

Pour installer Crosstool-NG, récupérez d'abord la version utilisée dans le cours, puis exécutez le script `bootstrap` :

```
$ cd $HOME
$ wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.26.0.tar.bz2
$ tar -xvf crosstool-ng-1.26.0.tar.bz2
$ cd crosstool-ng-1.26.0
$ ./bootstrap
```

> Note : un avertissement concernant `gl_HOST_CPU_C_ABI_32BIT` pourrait apparaître à la fin de l'exécution, il n'est pas important dans votre cas.

#### 1.1.1. Configuration et compilation de Crosstool-NG

Une fois la commande `./bootstrap` exécutée, en restant dans le même répertoire, utilisez `./configure` pour préparer la compilation et `make` pour le compiler :

```
$ ./configure --prefix=$HOME/crosstool-install
$ make && make install
```

Le paramètre _prefix_ indique l'endroit où les outils de Crosstool-NG doivent être installés. Vous devrez également ajouter ce chemin d'installation dans [votre variable d'environnement PATH](https://unix.stackexchange.com/questions/26047/how-to-correctly-add-a-path-to-path).  
* Si vous travaillez à l'aide de la machine virtuelle, cette configuration sera déjà faite.  
* Pour les ordinateurs du 0103/0105, vous devrez ajouter les 2 lignes suivante dans le fichier `~/.bashrc`
```
unset LD_LIBRARY_PATH
export PATH=$PATH:$HOME/crosstool-install/bin
```


> **Note** : il se peut que l'étape du `configure` échoue si vous effectuez l'installation sur votre ordinateur (sans utiliser la machine virtuelle du cours). Assurez-vous dans ce cas [d'avoir installé toutes les dépendances de Crosstool-NG](https://crosstool-ng.github.io/docs/os-setup/). Cette étape a déjà été effectuée pour vous sur les ordinateurs du lab ou avec la machine virtuelle fournie.


### 1.2. Configuration de l'environnement de compilation croisée

Nous allons maintenant préparer la compilation de l'environnement de compilation croisée (oui, c'est méta). Pour ce faire, Crosstool-NG a besoin d'informations sur notre système _cible_ (le Raspberry Pi). Créez tout d'abord un dossier nommé `ct-config-rpi-zero` dans votre dossier personnel et allez à l'intérieur :

```
$ cd $HOME
$ mkdir ct-config-rpi-zero
$ cd ct-config-rpi-zero
```

Au lieu de partir d'une configuration vide, nous allons utiliser en utiliser une spécialement préparée pour le cours. Dans le dossier `ct-config-rpi-zero`, téléchargez le fichier suivant et nommez le `.config` :

```
$ wget -O .config https://setr-ulaval.github.io/labo1-h25/etc/ct-ng-config
```


#### 1.2.1. Ajustement des chemins (paths)

La configuration telle que fournie est déjà prête à l'emploi **pour la machine virtuelle Fedora fournie**. Si vous utilisez un autre environnement (ex. votre propre installation Linux, les machines du 0103, etc.), vous **devez** la modifier afin d'éviter des problèmes qui vont entraîner des erreurs dans les prochains laboratoires!

> Cette sous-section n'est donc à effectuer _que si vous n'utilisez PAS_ la machine virtuelle fournie.

Pour se faire, lancez l'utilitaire de configuration de Crosstool-NG :

```
$ ct-ng menuconfig
```

Vous devriez alors obtenir une interface de ce type :

<img src="img/ct_im1.png" style="width:510px"/>

> **Important** : suivez _scrupuleusement_ les instructions suivantes. Tout manquement risque d'entraîner des erreurs ultérieures difficiles à interpréter et à corriger. Certains de ces changements peuvent avoir déjà été faits dépendant de la configuration de votre environnement. Si c'est le cas, laissez-les tels quel.

Allez dans la section _Paths and misc options_ et remplacez :

* _Prefix directory_ : `${HOME}/arm-cross-comp-env/${CT_TARGET}` (nous vous conseillons de conserver ce chemin, car les scripts de compilation fournis assument ce chemin précis)
<!-- * _Log to a file_ (tout en bas): désactivez l'option -->
<!--- * **Si vous utilisez un ordinateur du 0105** : Sur ces ordinateurs, il faut utiliser un dossier temporaire dédié et non pas l'espace de votre compte. Dans l'option _Working directory_. Remplacez donc `${CT_TOP_DIR}/.build` par `/gif3004/.build`.-->
<!--- * _Patches origin_ : `Bundled only` (**très important**, sinon vous vous retrouverez avec une longue suite d'erreurs à la compilation) -->


<!--- À droite, la configuration requise **sur un ordinateur du 0105**.-->
<!--- <img src="img/ct_im4.png" style="width:510px"/>-->

<!--- Dans la section _C compiler_, remplacez les valeurs suivantes :

* _Version of gcc_ : `6.4.0`
* _Additional supported languages_ : assurez-vous que `C++` est coché
 * _Core gcc extra config_ : **retirer** `--with-arch=armv6` (autrement dit, doit contenir seulement `--with-float=hard --with-fpu=vfp`)
* _Gcc extra config_ : **retirer** `--with-arch=armv6` (autrement dit, doit contenir seulement `--with-float=hard --with-fpu=vfp`)

<img src="img/ct_im2b.png" style="width:510px"/>-->

<!---
Dans la section _Target options_, nous allons spécifier au compilateur les caractéristiques exactes du matériel, de manière à ce qu'il puisse optimiser au maximum le code binaire généré. Remplacez les valeurs suivantes :

* _Target archicture_ : `arm`
* _Emit assembly for CPU_ : `arm1176jz-s`

<img src="img/ct_im3.png" style="width:510px"/>
-->

Dans la section _Operating System_, remplacez :

* _Source of linux_ : `Custom location`
* Une fois l'étape précédente effectuée, _Custom location_ : `chemin vers les sources du kernel`

Dans la dernière étape, `chemin vers les sources du kernel` doit être le chemin absolu vers le dossier contenant les sources du noyau Linux utilisé sur le Raspberry Pi. Téléchargez [l'archive suivante](http://wcours.gel.ulaval.ca/GIF3004/setrh24/linux-rpi-6.1.54-rt15.patched.tar.gz), décompressez-la et indiquez son chemin absolu.

<!--- Dans la section _C-library_, remplacez :

* _C library_ : `glibc`
* _Version of glibc_ : `2.24`

Dans la section _Binary utilities_, remplacez :

* _Version of binutils_ : `2.28.1`
-->

<!-- Dans la section _Debug facilities_ :

* Activez `gdb` et `strace`
* Allez ensuite dans les options de configuration de `gdb` (la touche Espace active ou désactive, la touche Entrée permet d'entrer dans les options) et _désactivez_ l'élément `Enable python scripting`

<img src="img/ct_im5.png" style="width:510px"/>
-->

N'oubliez pas d'enregistrer votre configuration (utilisez les flèches horizontales du clavier pour vous déplacer dans le menu du bas) puis quittez l'utilitaire.


### 1.3. Compilation et installation de la chaîne de compilation

Utilisez la commande suivante pour lancer la compilation :

```
$ ct-ng build
```

Cette compilation peut prendre un bon moment (comptez au moins 40 minutes), dépendant de la puissance de votre ordinateur. Si vous utilisez une machine virtuelle, pensez à augmenter le nombre de processeurs alloués à celle-ci, puisque Crosstool-NG peut en tirer parti. Vous aurez également besoin d'une bonne connexion Internet.


#### 1.3.1. Validation du contenu de la chaîne de compilation

Une fois cela fait, le répertoire `~/arm-cross-comp-env` devrait contenir un dossier nommé `arm-raspbian-linux-gnueabi`. Dans ce dossier, vous retrouverez plusieurs choses, mais en particulier :

* `bin/`, qui contient des exécutables x86-64 capables de générer du code machine ARM. Assurez-vous que ce dossier soit dans votre chemin d'exécution (PATH). Lorsque nous voudrons compiler un programme vers un binaire ARM, nous n'utiliserons donc pas `gcc` (qui compilerait en x86-64), mais bien `arm-raspbian-linux-gnueabi-gcc`
* `arm-raspbian-linux-gnueabi/sysroot`, qui contient les librairies et en-têtes des librairies centrales au système (libc, binutils, etc.). C'est là que le compilateur et l'éditeur de liens iront chercher les informations dont ils ont besoin.

> Note : si votre répertoire `~/arm-cross-comp-env` contient plutôt un dossier nommé `arm-raspbian-linux-gnueabihf` (avec "hf" à la fin), ajoutez ce suffixe à tous les endroits où on mentionne "arm-raspbian-linux-gnueabi" à partir d'ici.

### 1.4. Synchronisation avec le Raspberry Pi

> **Important** : attendez que l'étape précédente soit _terminée sans erreurs_ avant de continuer.

À ce stade, vous êtes en possession d'une chaîne de compilation croisée. Il vous faut toutefois maintenant la synchroniser avec le Raspberry Pi, de manière à vous assurer que les versions des librairies et des en-têtes soient les mêmes lorsque vous compilerez (sur votre ordinateur) et exécuterez (sur le Raspberry Pi). Il va falloir synchroniser trois répertoires :

* /usr/lib et /lib, qui contiennent les librairies partagées (fichier .so) qui peuvent être utilisées par les programmes;
* /usr/include, qui contient les en-têtes de ces librairies (nécessaires pour la compilation);
* /opt, qui contient certains fichiers de configuration importants.

Pour synchroniser ces dossiers, nous allons utiliser `rsync`. Cet outil permet de faire des mises à jour _incrémentales_, c'est-à-dire que seules les différences sont transférées. Notez que vous devez modifier `adresse_ip_ou_nom_dhote` pour l'adresse ou le DNS de votre Raspberry Pi dans les commandes suivantes.

```
$ cd ~/arm-cross-comp-env/arm-raspbian-linux-gnueabi/arm-raspbian-linux-gnueabi
$ rsync -av --numeric-ids --exclude "*.ko" --exclude "*.fw" --exclude "/opt/vc/src" --delete pi@adresse_ip_ou_nom_dhote:{/lib,/opt} sysroot
$ rsync -av --numeric-ids --exclude "/usr/lib/.debug" --delete pi@adresse_ip_ou_nom_dhote:{/usr/lib,/usr/include} sysroot/usr
```

Il reste par la suite un petit problème à corriger. Beaucoup de fichiers sont en fait des _liens_, qui évitent de devoir stocker deux fois le même fichier inutilement. Toutefois, certains de ces liens sont _absolus_, c'est-à-dire qu'ils contiennent un chemin absolu. Vous pouvez constater ce problème en testant, par exemple :

```
$ ls -l sysroot/usr/lib/arm-linux-gnueabihf/libm.so 
lrwxrwxrwx 1 setr setr 34  3 oct 16:45 sysroot/usr/lib/arm-linux-gnueabihf/libm.so -> /lib/arm-linux-gnueabihf/libm.so.6
```

Comme on le voit, le lien pointe vers un chemin absolu, qui n'existe pas sur notre plateforme de compilation (votre terminal devrait d'ailleurs vous l'afficher en rouge). Il y a plusieurs solutions pour corriger ce problème, vous pouvez consulter [cette page](https://unix.stackexchange.com/questions/100918/convert-absolute-symlink-to-relative-symlink-with-simple-linux-command) pour en savoir plus, mais le plus simple est d'utiliser la commande suivante. Attention, le `find` doit être exécuté *dans* le répertoire _sysroot_, sinon les chemins ne seront pas convertis correctement!

```
$ cd ~/arm-cross-comp-env/arm-raspbian-linux-gnueabi/arm-raspbian-linux-gnueabi/sysroot
$ find . -lname '/*' | while read l ; do   echo ln -sf $(echo $(echo $l | sed 's|/[^/]*|/..|g')$(readlink $l) | sed 's/.....//') $l; done | sh
```

> Vous devrez effectuer cette synchronisation _à chaque fois_ que vous ajouterez une librairie ou mettrez à jour votre système sur le Raspberry Pi.

> Ignorez l'erreur éventuelle concernant `/usr/lib/ssl/certs/certs`, ce répertoire ne sera pas nécessaire dans le cadre du cours

### 1.5. Préparation d'une configuration CMake

[CMake](https://cmake.org/cmake/help/v3.27) est un outil permettant de mettre en place une chaîne de compilation efficace et portable. Nous allons l'utiliser dans le cadre du cours afin d'automatiser la compilation et l'édition de liens des TP. Pour ce faire, créez un nouveau fichier dans `arm-cross-comp-env/`, nommé `rpi-zero-w-toolchain.cmake` et insérez-y le contenu suivant :

```
# Identification du systeme cible
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION 6.1)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Localisation du sysroot
set(CMAKE_SYSROOT $ENV{HOME}/arm-cross-comp-env/arm-raspbian-linux-gnueabi/arm-raspbian-linux-gnueabi/sysroot)

# Selection du compilateur
set(tools $ENV{HOME}/arm-cross-comp-env/arm-raspbian-linux-gnueabi)
set(CMAKE_C_COMPILER ${tools}/bin/arm-raspbian-linux-gnueabi-gcc)
set(CMAKE_CXX_COMPILER ${tools}/bin/arm-raspbian-linux-gnueabi-g++)

# On ajoute des options au compilateur pour lui indiquer ou aller chercher les librairies
SET(FLAGS "-Wl,-rpath-link,${CMAKE_SYSROOT}/opt/vc/lib -Wl,-rpath-link,${CMAKE_SYSROOT}/lib/arm-linux-gnueabihf -Wl,-rpath-link,${CMAKE_SYSROOT}/usr/lib/arm-linux-gnueabihf -Wl,-rpath-link,${CMAKE_SYSROOT}/usr/local/lib")
SET(CMAKE_CXX_FLAGS ${FLAGS} CACHE STRING "" FORCE)
SET(CMAKE_C_FLAGS ${FLAGS} CACHE STRING "" FORCE)

# Quoi aller chercher dans la sysroot (on ne veut pas aller chercher les programmes puisqu'ils sont
# compiles en ARM et ne peuvent donc etre directement executes sur un processeur x86)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
```

Nous réutiliserons cette configuration générique pour tous les projets du cours. Nous verrons plus loin comment la lier aux dits projets.
