#requires -version 3.0

param([switch]$dotfiles)

# note: $scoopdir is also configured inside profile.ps1
$scoopdir = "$env:USERPROFILE\Scoop"
$projectdir = "$env:USERPROFILE\Projects"
$dotfilesdir = "$env:USERPROFILE\Projects\dotfiles"

$linkhomefiles = "home\*"
$linkappdatafiles = "appdata\*"
$linkcustomfiles = "custom\*"
$linkdestExtension = "destination"

$errorActionPreference = 'stop'

function echo-withstyle($msg, $color) {
    # because... um...
    write-host -nonewline '['
    write-host -nonewline 'dotfiles' -foregroundcolor blue
    write-host -nonewline '] '
    write-host $msg -foregroundcolor $color
}

function info-withstyle($msg) {
    echo-withstyle $msg white
}

function success-withstyle($msg) {
    echo-withstyle $msg green
}

function warn-withstyle($msg) {
    echo-withstyle $msg yellow
}

function error-withstyle($msg) {
    echo-withstyle $msg red
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

function is-dirempty($path) {
    $info = gci $path | measure-object
    return $info.count -eq 0
}

function remove-smartly($path) {

    $exists = test-path $path
    if (!($exists)) { return }

    $isdir = test-path -pathtype container $path
    $file = get-item -force $path
    $issymlink = [bool]($file.attributes -band [io.fileattributes]::reparsePoint)

    if ($isdir -and $issymlink) {
        $output = cmd /c "rmdir $path" 2>&1
        if ($LASTEXITCODE -ne 0) {
            error-withstyle "RMDIR failed. Exit code:$LASTEXITCODE`n$output"
        }
        else {
            write-host $output
        }
    }
    elseif ($isdir) {
        remove-item -recurse -force $path
    }
    else {
        remove-item -force $path
    }

}

function install-myuniverse {

    function ensure-install($app) {
        # in case it's already installed:
        scoop update $app
        if ($LASTEXITCODE -eq 0) {return}
        $i = 4
        while($i -gt 0) {
            scoop install $app
            if ($LASTEXITCODE -eq 0) {return}
            warn-withstyle "Failed installing $app. Retrying..."
            scoop uninstall $app
            $i--
        }
        error-withstyle "Ran out of patience"
        error-withstyle "Skipping app $app"
    }
    function ensure-bucketadd($bucket, $url) {
        $isinstalled = (scoop bucket list) -match $bucket
        if ($isinstalled) {
            scoop update
            return
        }
        $i = 4
        while($i -gt 0) {
            scoop bucket add $bucket $url
            if ($LASTEXITCODE -eq 0) {return}
            warn-withstyle "Failed. Retrying..."
            $i--
        }
        error-withstyle "Ran out of patience"
        error-withstyle "Skipping bucket $bucket ($url)"
    }
    function ensure-iex($url) {
        $i = 4
        while($i -gt 0) {
            try {
                write-host "Installing from url: $url"
                iex (new-object net.webclient).downloadstring($url)
            }
            catch {
                $i--
                write-host $_.exception.tostring() -foregroundcolor darkred
                warn-withstyle "Something failed. Retrying..."
                continue
            }
            return
            # speghetti, yum...
        }
        error-withstyle "Ran out of patience, skipping $url"
    }

    info-withstyle 'Let the installation begin!!'

    info-withstyle 'Creating directories'
    ensure-path $scoopdir
    ensure-path $projectdir

    info-withstyle 'Setting SCOOP variable'
    $env:SCOOP = $scoopdir
    [environment]::setEnvironmentVariable('SCOOP', $scoopdir, 'User')

    $webclient = new-object net.webclient

    info-withstyle 'Installing scoop'
    ensure-iex('https://get.scoop.sh/')

    info-withstyle 'Installing scoop apps'

    # utils
    ensure-install '7zip';
    ensure-install 'cowsay';
    ensure-install 'sudo';
    ensure-install 'ln';
    ensure-install 'openssh';
    ensure-install 'git';

    # https://github.com/lukesampson/scoop/issues/517
    [environment]::setenvironmentvariable('GIT_SSH', (resolve-path (scoop which ssh)), 'User')

    # buckets (requires git)
    ensure-bucketadd 'extras';
    ensure-bucketadd 'ernwong' 'https://github.com/ErnWong/scoop-bucket.git'

    # build tools
    ensure-install 'gcc';
    ensure-install 'msys';
    ensure-install 'cmake';

    # TODO:
    # ensure-install 'gcc-arm-none-eabi';

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
    ensure-iex('http://psget.net/GetPsGet.ps1')

    info-withstyle 'Installing PsGet modules'
    install-module posh-git

    download-dotfiles
    setup-dotfiles

    success-withstyle 'Done.'
    success-withstyle 'Your new home should be ready now. Enjoy!'
}

function download-dotfiles {
    info-withstyle 'Downloading dotfiles'
    if ((test-path $dotfilesdir) -and !(is-dirempty $dotfilesdir))
    {
        write-host "Dotfiles directory already exists at $dotfilesdir"
        $shouldRemove = read-yesno 'Remove?'
        if (!$shouldRemove) {
            write-host "Skipping dotfiles download"
            return
        }
        write-host "Deleting contents of $dotfilesdir"
        remove-smartly $dotfilesdir
        new-item $dotfilesdir -itemtype directory
    }
    git clone --recursive 'https://github.com/ErnWong/dotfiles.git' $dotfilesdir
}

function setup-dotfiles {

    function link-item($target, $linkname) {
        $destdir = split-path $linkname
        ensure-path $destdir
        if (test-path $linkname) {
            write-host "Item $linkname already exists."
            $shouldRemove = read-yesno 'Remove?'
            if (!$shouldRemove) {
                write-host "Skipping $linkname"
                return
            }
            write-host "Deleting $linkname"
            remove-smartly $linkname
        }
        write-host "Symlinking $linkname to $target"
        $mklink_arg = ''
        if (test-path -pathtype container $target) {
            $mklink_arg = '/d'
        }
        $output = cmd /c "mklink $mklink_arg `"$linkname`" `"$target`"" 2>&1
        if ($LASTEXITCODE -ne 0) {
            error-withstyle "MKLINK failed. Exit code: $LASTEXITCODE`n$output"
        }
        else {
            write-host $output
        }
    }

    info-withstyle 'Hardlinking dotfiles'

    pushd $dotfilesdir
    foreach ($item in get-childitem $linkhomefiles) {
        link-item $item.fullname "$env:USERPROFILE\$($item.name)"
    }
    foreach ($item in get-childitem $linkappdatafiles) {
        link-item $item.fullname "$env:APPDATA\$($item.name)"
    }
    foreach ($item in get-childitem $linkcustomfiles) {
        if ($item.extension -eq ".$linkdestextension") {
            continue
        }
        $destfile = "$($item.fullname).$linkdestExtension"
        if (!(test-path $destfile)) {
            write-host "Can't find $destfile" -foregroundcolor yellow
            write-host "Skipping $($item.fullname)" -foregroundcolor yellow
            return
        }
        $destination = get-content $destfile
        $destination = [environment]::expandEnvironmentVariables($destination)
        link-item $item.fullname $destination
    }
    popd

}

if ($dotfiles) { setup-dotfiles }
else { install-myuniverse }
