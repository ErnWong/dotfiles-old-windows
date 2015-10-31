#requires -version 3.0

param([switch]$dotfiles, [switch]$vim)

# note: $scoopdir is also configured inside profile.ps1
$scoopdir = "$env:USERPROFILE\Scoop"
$projectdir = "$env:USERPROFILE\Projects"
$dotfilesdir = "$env:USERPROFILE\Projects\dotfiles"

$linkhomefiles = "*.linktohome"
$linkappdatafiles = "*.linktoappdata"
$linkcustomfiles = "*.linktocustom"
$linkdestExtension = "linkdestination"

$errorActionPreference = 'stop'

function info-withstyle($msg) {
    # just because
    write-host -nonewline '['
    write-host -nonewline 'dotfiles' -foregroundcolor Blue
    write-host -nonewline '] '
    write-host $msg
}

function read-yesno($prompt) {
    while ($true) {
        $in = read-host "$prompt (y/n)"
        if ($in -eq 'y') {return $true}
        if ($in -eq 'n') {return $false}
    }
}

function ensure-path($path) {
    if (test-path $path) {return}
    new-item -itemtype directory -path $path
}

function install-myuniverse {

    function ensure-install($app) {
        $i = 4
        while($i -gt 0) {
            scoop install $app
            if ($?) {return}
            scoop uninstall $app
            $i--
        }
    }
    function ensure-bucketadd($bucket, $url) {
        $i = 4
        while($i -gt 0) {
            scoop bucket add $bucket $url
            if ($?) {return}
            $i--
        }
    }

    info-withstyle 'Let the installation begin!!'

    info-withstyle 'Creating directories'
    $env:SCOOP = $scoopdir
    ensure-path $scoopdir
    ensure-path $projectdir

    $webclient = new-object net.webclient

    info-withstyle 'Saving PATH variable for later'
    $oldPath = [environment]::getEnvironmentVariable('path', 'user')

    info-withstyle 'Installing scoop'
    invoke-expression $webclient.downloadstring('https://get.scoop.sh/')

    info-withstyle 'Reverting PATH variable'
    [environment]::setEnvironmentVariable('path', $oldPath, 'user')

    info-withstyle 'Installing scoop apps'

    # utils
    ensure-install '7zip';
    ensure-install 'cowsay';
    ensure-install 'ln';
    ensure-install 'git';

    # buckets
    ensure-bucketadd 'extras';
    ensure-bucketadd 'ernwong' 'https://github.com/ErnWong/scoop-bucket.git'

    # build tools
    ensure-install 'gcc';
    ensure-install 'msys';
    ensure-install 'gcc-arm-none-eabi';

    # languages
    ensure-install 'nodejs';
    ensure-install 'python';
    ensure-install 'python27';
    ensure-install 'ruby';
    ensure-install 'perl';
    ensure-install 'latex';
    ensure-install 'pandoc';

    ensure-install 'conemu';
    ensure-install 'vim-ernwong';

    info-withstyle 'Installing PsGet';
    invoke-expression $webclient.downloadstring('http://psget.net/GetPsGet.ps1')

    info-withstyle 'Installing PsGet modules'
    install-module posh-git

    info-withstyle 'Downloading dotfiles'
    git clone 'https://github.com/ErnWong/dotfiles.git' $dotfilesdir

    . "$dotfilesdir\setup dotfiles"
    . "$dotfilesdir\setup vim"

    info-withstyle 'Done.'
    info-withstyle 'Your new home should be ready now. Enjoy!'
}

function setup-dotfiles {

    function link-item($target, $linkname) {
        $destdir = split-path $linkname
        ensure-path $destdir
        if (test-path $linkname) {
            write-host "Item $linkname already exists."
            $shouldRemove = read-yesno 'Remove?'
            if (!shouldRemove) {
                write-host "Skipping $linkname"
                return
            }
            write-host "RM $linkname"
            remove-item $linkname
        }
        write-host "LN $args"
        ln $target $linkname;
    }

    info-withstyle 'Hardlinking dotfiles'

    pushd $dotfilesdir
    foreach ($item in get-childitem $linkhomefiles) {
        link-item -s $item.name $env:USERPROFILE
    }
    foreach ($item in get-childitem $linkappdatafiles) {
        link-item -s $item.name $env:APPDATA
    }
    foreach ($item in get-childitem $linkcustomfiles) {
        $destfile = "$($item.basename).$linkdestExtension"
        if (!test-path $destfile) {
            write-host "Can't find $destfile"
            write-host "Skipping $(item.name)"
        }
        $destination = get-content $destfile
        $destination = [environment]::expandEnvironmentVariables($destination)
        link-item -s $item.name $destination
    }
    popd

}

function setup-vim {
    info-withstyle 'Opening vim for you to install plugins'
    vim
}

if ($dotfiles) { setup-dotfiles }
elseif ($vim) { setup-vim}
else { install-myuniverse }
