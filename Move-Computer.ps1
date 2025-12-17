Write-Verbose "Getting Computer Name..."
$hostname = hostname

$session = New-PSSession -ComputerName ComputerName -Credential (Get-Credential)
Invoke-Command -Session $session -ArgumentList $hostname -ScriptBlock {
    param (
        $hostname
        )
    Import-Module ActiveDirectory

$hash = @{
    "Staff"      = 1;
    "AVP"        = 2;
    "Management" = 3;
    "Sales"      = 4;
    "Operations" = 5;
    "Corporate"  = 6;
    "Core"       = 7;
    "Testing"    = 8;
    "IT"         = 9;
    "Training"   = 10;
}

    $hash.GetEnumerator() | Sort-Object -Property Value
    $targetpath = Read-Host "Enter a value from above for the Workstation OU"
    switch ($targetpath) {
        '1' { Set-Variable -Name targetpath -Value "OU-PATH1"  }
        '2' { Set-Variable -Name targetpath -Value "OU-PATH2"  }
        '3' { Set-Variable -Name targetpath -Value "OU-PATH3"  }
        '4' { Set-Variable -Name targetpath -Value "OU-PATH4"  }
        '5' { Set-Variable -Name targetpath -Value "OU-PATH5"  }
        '6' { Set-Variable -Name targetpath -Value "OU-PATH6"  }
        '7' { Set-Variable -Name targetpath -Value "OU-PATH7"  }
        '8' { Set-Variable -Name targetpath -Value "OU-PATH8"  }
        '9' { Set-Variable -Name targetpath -Value "OU-PATH9"  }
        '10' { Set-Variable -Name targetpath -Value "OU-PATH0"  }
        Default {Set-Variable -Name targetpath -Value "OU-PATH99"}
    }
    
    Get-ADComputer -Identity $hostname | Move-AdObject -TargetPath $targetpath
    $hostname = $hostname + "$"
    Add-AdGroupMember -Identity Intune -Members $hostname
        
} #scriptblock