$here = (Split-Path -Parent $MyInvocation.MyCommand.Path).Replace(".Tests", "")
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\..\psmake\ext\psmake.core.ps1"
. "$here\$sut"

# Prepare test context
$Context = Create-Object @{MakeDirectory=$PSScriptRoot; NuGetExe='.nuget\nuget.exe';}

# Prepare test projects
call "$($env:windir)\Microsoft.NET\Framework64\v4.0.30319\msbuild.exe" "$PSScriptRoot\TestSolution\Testsolution.sln" /t:"Clean,Build" /p:Configuration=Release /m /verbosity:m /nologo /p:TreatWarningsAsErrors=true

$PassingNUnit1 = "$PSScriptRoot\TestSolution\Passing.NUnit.Tests1\bin\Release\Passing.NUnit.Tests1.dll"
$PassingNUnit2 = "$PSScriptRoot\TestSolution\Passing.NUnit.Tests2\bin\Release\Passing.NUnit.Tests2.dll"
$FailingNUnit = "$PSScriptRoot\TestSolution\Failing.NUnit.Tests\bin\Release\Failing.NUnit.Tests.dll"

$PassingMbUnit1 = "$PSScriptRoot\TestSolution\Passing.MbUnit.Tests1\bin\Release\Passing.MbUnit.Tests1.dll"
$PassingMbUnit2 = "$PSScriptRoot\TestSolution\Passing.MbUnit.Tests2\bin\Release\Passing.MbUnit.Tests2.dll"
$FailingMbUnit =  "$PSScriptRoot\TestSolution\Failing.MbUnit.Tests\bin\Release\Failing.MbUnit.Tests.dll"

$PassingMsTest1 = "$PSScriptRoot\TestSolution\Passing.MsTest.Tests1\bin\Release\Passing.MsTest.Tests1.dll"
$PassingMsTest2 = "$PSScriptRoot\TestSolution\Passing.MsTest.Tests2\bin\Release\Passing.MsTest.Tests2.dll"
$FailingMsTest = "$PSScriptRoot\TestSolution\Failing.MsTest.Tests\bin\Release\Failing.MsTest.Tests.dll"

Describe "Define-NUnitTests" {
    
    It "It should use group name as report name if second is not sepcified" {
        $def = Define-NUnitTests -GroupName 'my group' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.GroupName | Should Be 'my group'
        $def.ReportName | Should Be 'my_group'
    }

    It "It should define tests with group name and report name" {
        $def = Define-NUnitTests -GroupName 'my group' -ReportName 'test-reports' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.GroupName | Should Be 'my group'
        $def.ReportName | Should Be 'test-reports'
    }

    It "It should define tests with default runner version" {
        $def = Define-NUnitTests -GroupName 'my group' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.PackageVersion | Should Be '2.6.4'
    }

    It "It should define tests with sepcified runner version" {
        $def = Define-NUnitTests -GroupName 'my group' -NUnitVersion '2.6.2' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.PackageVersion | Should Be '2.6.2'
    }
        
    It "It should allow to specify one assembly" {
        $def = Define-NUnitTests -GroupName 'group' -TestAssembly $PassingNUnit1
        $def | Should Not Be $null
        $def.Assemblies.GetType() | Should Be 'string[]'
        $def.Assemblies.Length | Should Be 1
        $def.Assemblies[0] | Should Be $PassingNUnit1
    }

    It "It should allow to specify multiple assemblies" {
        $def = Define-NUnitTests -GroupName 'group' -TestAssembly $PassingNUnit1, $PassingNUnit2
        $def | Should Not Be $null
        $def.Assemblies.GetType() | Should Be 'string[]'
        $def.Assemblies.Length | Should Be 2
        $def.Assemblies[0] | Should Be $PassingNUnit1
        $def.Assemblies[1] | Should Be $PassingNUnit2
    }

    It "It should resolve assembly names with wildcards" {
        $def = Define-NUnitTests -GroupName 'group' -TestAssembly "$PSScriptRoot\TestSolution\*\bin\Release\*.NUnit.Tests*.dll"
        $def | Should Not Be $null
        $def.Assemblies.GetType() | Should Be 'string[]'
        $def.Assemblies.Length | Should Be 3
        $def.Assemblies.Contains($PassingNUnit1) | Should Be $true
        $def.Assemblies.Contains($PassingNUnit2) | Should Be $true
        $def.Assemblies.Contains($FailingNUnit) | Should Be $true
    }
}

Describe "Define-MbUnitTests" {
    
    It "It should use group name as report name if second is not sepcified" {
        $def = Define-MbUnitTests -GroupName 'my group' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.GroupName | Should Be 'my group'
        $def.ReportName | Should Be 'my_group'
    }

    It "It should define tests with group name and report name" {
        $def = Define-MbUnitTests -GroupName 'my group' -ReportName 'test-reports' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.GroupName | Should Be 'my group'
        $def.ReportName | Should Be 'test-reports'
    }

    It "It should define tests with default runner version" {
        $def = Define-MbUnitTests -GroupName 'my group' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.PackageVersion | Should Be '3.4.14'
    }

    It "It should define tests with sepcified runner version" {
        $def = Define-MbUnitTests -GroupName 'my group' -MbUnitVersion '3.4.15.0' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.PackageVersion | Should Be '3.4.15.0'
    }
        
    It "It should allow to specify one assembly" {
        $def = Define-MbUnitTests -GroupName 'group' -TestAssembly $PassingMbUnit1
        $def | Should Not Be $null
        $def.Assemblies.GetType() | Should Be 'string[]'
        $def.Assemblies.Length | Should Be 1
        $def.Assemblies[0] | Should Be $PassingMbUnit1
    }

    It "It should allow to specify multiple assemblies" {
        $def = Define-MbUnitTests -GroupName 'group' -TestAssembly $PassingMbUnit1, $PassingMbUnit2
        $def | Should Not Be $null
        $def.Assemblies.GetType() | Should Be 'string[]'
        $def.Assemblies.Length | Should Be 2
        $def.Assemblies[0] | Should Be $PassingMbUnit1
        $def.Assemblies[1] | Should Be $PassingMbUnit2
    }

    It "It should resolve assembly names with wildcards" {
        $def = Define-MbUnitTests -GroupName 'group' -TestAssembly "$PSScriptRoot\TestSolution\*\bin\Release\*.MbUnit.Tests*.dll"
        $def | Should Not Be $null
        $def.Assemblies.GetType() | Should Be 'string[]'
        $def.Assemblies.Length | Should Be 3
        $def.Assemblies.Contains($PassingMbUnit1) | Should Be $true
        $def.Assemblies.Contains($PassingMbUnit2) | Should Be $true
        $def.Assemblies.Contains($FailingMbUnit) | Should Be $true
    }
}

Describe "Define-MsTests" {
    
    It "It should use group name as report name if second is not sepcified" {
        $def = Define-MsTests -GroupName 'my group' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.GroupName | Should Be 'my group'
        $def.ReportName | Should Be 'my_group'
    }

    It "It should define tests with group name and report name" {
        $def = Define-MsTests -GroupName 'my group' -ReportName 'test-reports' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.GroupName | Should Be 'my group'
        $def.ReportName | Should Be 'test-reports'
    }

    It "It should define tests with default runner version" {
        $def = Define-MsTests -GroupName 'my group' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.Runner | Should Match '12\.0'
    }

    It "It should define tests with sepcified runner version" {
        $def = Define-MsTests -GroupName 'my group' -VisualStudioVersion '11.0' -TestAssembly "some.dll"
        $def | Should Not Be $null
        $def.Runner | Should Match '11\.0'
    }
        
    It "It should allow to specify one assembly" {
        $def = Define-MsTests -GroupName 'group' -TestAssembly $PassingMsTest1
        $def | Should Not Be $null
        $def.Assemblies.GetType() | Should Be 'string[]'
        $def.Assemblies.Length | Should Be 1
        $def.Assemblies[0] | Should Be $PassingMsTest1
    }

    It "It should allow to specify multiple assemblies" {
        $def = Define-MsTests -GroupName 'group' -TestAssembly $PassingMsTest1, $PassingMsTest2
        $def | Should Not Be $null
        $def.Assemblies.GetType() | Should Be 'string[]'
        $def.Assemblies.Length | Should Be 2
        $def.Assemblies[0] | Should Be $PassingMsTest1
        $def.Assemblies[1] | Should Be $PassingMsTest2
    }

    It "It should resolve assembly names with wildcards" {
        $def = Define-MsTests -GroupName 'group' -TestAssembly "$PSScriptRoot\TestSolution\*\bin\Release\*.MsTest.Tests*.dll"
        $def | Should Not Be $null
        $def.Assemblies.GetType() | Should Be 'string[]'
        $def.Assemblies.Length | Should Be 3
        $def.Assemblies.Contains($PassingMsTest1) | Should Be $true
        $def.Assemblies.Contains($PassingMsTest2) | Should Be $true
        $def.Assemblies.Contains($FailingMsTest) | Should Be $true
    }
}

Describe "Run-Tests" {
    
    It "It should allow to successfully run NUnit tests with one assembly and generate reports" {
        Define-NUnitTests -GroupName 'rt1' -TestAssembly $PassingNUnit1 | Run-Tests
        $? | Should Be $true
        Test-Path 'reports\rt1.xml' | Should Be $true
    }

    It "It should throw if NUnit fails any test" {
        try
        {
            Define-NUnitTests -GroupName 'rt2' -TestAssembly $FailingNUnit | Run-Tests
            throw 'Fail'
        }
        catch [Exception]
        {
            $_.Exception.Message | Should Be 'A program execution was not successful (Exit code: 1).'
            Test-Path 'reports\rt2.xml' | Should Be $true
        }
    }

    It "It should allow to successfully run MbUnit tests with one assembly and generate reports" {
        Define-MbUnitTests -GroupName 'rt3' -TestAssembly $PassingMbUnit1 | Run-Tests
        $? | Should Be $true
        Test-Path 'reports\rt3.xml' | Should Be $true
    }

    It "It should throw if MbUnit fails any test" {
        try
        {
            Define-MbUnitTests -GroupName 'rt4' -TestAssembly $FailingMbUnit | Run-Tests
            throw 'Fail'
        }
        catch [Exception]
        {
            $_.Exception.Message | Should Be 'A program execution was not successful (Exit code: 1).'
            Test-Path 'reports\rt4.xml' | Should Be $true
        }
    }

    It "It should allow to successfully run MsTest tests with one assembly and generate reports" {
        Define-MsTests -GroupName 'rt5' -TestAssembly $PassingMsTest1 | Run-Tests
        $? | Should Be $true
        Test-Path 'reports\rt5.trx' | Should Be $true
    }

    It "It should throw if MsTest fails any test" {
        try
        {
            Define-MsTests -GroupName 'rt6' -TestAssembly $FailingMsTest | Run-Tests
            throw 'Fail'
        }
        catch [Exception]
        {
            $_.Exception.Message | Should Be 'A program execution was not successful (Exit code: 1).'
            Test-Path 'reports\rt6.trx' | Should Be $true
        }
    }

    It "It should allow to successfully run multiple test groups and generate reports" {
        $tests = @()
        $tests += Define-NUnitTests -GroupName 'rt7' -TestAssembly $PassingNUnit1,$PassingNUnit2
        $tests += Define-MbUnitTests -GroupName 'rt8' -TestAssembly $PassingMbUnit1,$PassingMbUnit2
        $tests += Define-MsTests -GroupName 'rt9' -TestAssembly $PassingMsTest1,$PassingMsTest2
        $tests | Run-Tests
        $? | Should Be $true
        Test-Path 'reports\rt7.xml' | Should Be $true
        Test-Path 'reports\rt8.xml' | Should Be $true
        Test-Path 'reports\rt9.trx' | Should Be $true
    }

    It "It should stop on a first failing group" {
        $tests = @()
        $tests += Define-NUnitTests -GroupName 'rt10' -TestAssembly $PassingNUnit1
        $tests += Define-NUnitTests -GroupName 'rt11' -TestAssembly $FailingNUnit
        $tests += Define-NUnitTests -GroupName 'rt12' -TestAssembly $PassingNUnit2
        try
        {
            $tests | Run-Tests
            throw 'Fail'
        }
        catch [Exception]
        {
            $_.Exception.Message | Should Be 'A program execution was not successful (Exit code: 1).'
            Test-Path 'reports\rt10.xml' | Should Be $true
            Test-Path 'reports\rt11.xml' | Should Be $true
            Test-Path 'reports\rt12.xml' | Should Be $false
        }
    }

    It "It should allow to cover tests and generate reports" {
        $tests = @()
        $tests += Define-NUnitTests -GroupName 'rt13' -TestAssembly $PassingNUnit1
        $tests += Define-MbUnitTests -GroupName 'rt14' -TestAssembly $PassingMbUnit2
        $tests += Define-MsTests -GroupName 'rt15' -TestAssembly $PassingMsTest1
        $tests | Run-Tests -Cover -CodeFilter "+[Domain*]* -[*Tests*]*" -TestFilter "*Tests*.dll"
        $? | Should Be $true
        Test-Path 'reports\rt13.xml' | Should Be $true
        Test-Path 'reports\rt14.xml' | Should Be $true
        Test-Path 'reports\rt15.trx' | Should Be $true
        Test-Path 'reports\rt13_coverage.xml' | Should Be $true
        Test-Path 'reports\rt14_coverage.xml' | Should Be $true
        Test-Path 'reports\rt15_coverage.xml' | Should Be $true
    }

    It "It should clean reports directory" {
        Define-NUnitTests -GroupName 'rt1' -TestAssembly $PassingNUnit1 | Run-Tests -EraseReportDirectory
        $? | Should Be $true
        Test-Path 'reports\rt1.xml' | Should Be $true
        (ls 'reports').Count | Should Be 1
    }
}

Describe "Generate-CoverageSummary" {
    
    It "It should generate coverage summary from coverage reports" {
        $tests = @()
        $tests += Define-NUnitTests -GroupName 'rt16' -TestAssembly $PassingNUnit1
        $tests += Define-MbUnitTests -GroupName 'rt17' -TestAssembly $PassingMbUnit2
        $tests += Define-MsTests -GroupName 'rt18' -TestAssembly $PassingMsTest1
        $tests | Run-Tests -Cover -CodeFilter "+[Domain*]* -[*Tests*]*" -TestFilter "*Tests*.dll" | Generate-CoverageSummary
        $? | Should Be $true
        Test-Path 'reports\summary\summary.xml' | Should Be $true
        Test-Path 'reports\summary\index.htm' | Should Be $true
    }
}

Describe "Check-AcceptableCoverage" {
    
    It "It should allow to verify test coverage" {
        $tests = @()
        $tests += Define-NUnitTests -GroupName 'rt19' -TestAssembly $PassingNUnit1
        $tests += Define-MbUnitTests -GroupName 'rt20' -TestAssembly $PassingMbUnit2
        $tests += Define-MsTests -GroupName 'rt21' -TestAssembly $PassingMsTest1
        $tests | Run-Tests -Cover -CodeFilter "+[Domain*]* -[*Tests*]*" -TestFilter "*Tests*.dll" | Generate-CoverageSummary | Check-AcceptableCoverage -AcceptableCoverage 66
        $? | Should Be $true
    }

    It "It should throw if test coverage does not meet acceptable level" {
        try
        {
            Define-NUnitTests -GroupName 'rt22' -TestAssembly $PassingNUnit1 | Run-Tests -Cover -CodeFilter "+[Domain*]* -[*Tests*]*" -TestFilter "*Tests*.dll" | Generate-CoverageSummary | Check-AcceptableCoverage -AcceptableCoverage 66
            throw 'Fail'
        }
        catch [Exception]
        {
            $_.Exception.Message | Should Be 'Coverage 33.3% is below threshold 66%'
        }
    }
}