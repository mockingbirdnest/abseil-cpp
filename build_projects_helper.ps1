# This script helps creating project files for abseil-cpp.  The argument is the path of a subdirectory of absl/.
# It produces a pair of *.vcxproj, *.vcxproj.filters files for the subdirectory being operated upon.  It also
# appends to *.vcxproj and *.vcxproj.filters files for the tests and benchmarks.  The generated XML may just
# be inserted at the right place in the project files, replacing whatever was there.
#
# Command to run:
#   foreach ($p in 'algorithm','base','cleanup','container','copts','crc','debugging','flags','functional','hash','log','memory','meta','numeric','profiling','random','status','strings','synchronization','time','types','utility') { ..\build_projects_helper.ps1 $p }

$dir = resolve-path $args[0]
$vcxprojname = [string]::format("{0}_vcxproj.txt", $dir)

$filtersheaders = "  <ItemGroup>`r`n"
$vcxprojheaders = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\*" -Include *.h -Exclude *_test.h,*_test_*.h,test_*.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filtersheaders +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojheaders +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
$filtersheaders += "  </ItemGroup>`r`n"
$vcxprojheaders += "  </ItemGroup>`r`n"

$filterssources = "  <ItemGroup>`r`n"
$vcxprojsources = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\*" -Include *.cc -Exclude *_benchmark.cc,*benchmarks.cc,*_test.cc,*_testing.cc,*_test_*.cc,test_*.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filterssources +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojsources +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filterssources += "  </ItemGroup>`r`n"
$vcxprojsources += "  </ItemGroup>`r`n"

$filtersbenchmarks = "  <ItemGroup>`r`n"
$vcxprojbenchmarks = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\*" -Recurse -Include *_benchmark.cc,*benchmarks.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filtersbenchmarks +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojbenchmarks +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filtersbenchmarks += "  </ItemGroup>`r`n"
$vcxprojbenchmarks += "  </ItemGroup>`r`n"

$filterstests = "  <ItemGroup>`r`n"
$vcxprojtests = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\*" -Include *_test.h,*_test_*.h,test_*.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\*\*" -Recurse -Include *_test.h,*_testing.h,*_test_*.h,test_*.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Header Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\*" -Recurse -Include *_test.cc,*_testing.cc,*_test_*.cc,test_*.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filterstests +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filterstests += "  </ItemGroup>`r`n"
$vcxprojtests += "  </ItemGroup>`r`n"

$filtersinternals = "  <ItemGroup>`r`n"
$vcxprojinternals = "  <ItemGroup>`r`n"

Get-ChildItem "$dir\*\*" -Recurse -Include *.h -Exclude *_test.h,*_testing.h,*_test_*.h,test_*.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filtersinternals +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojinternals +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\*\*" -Recurse -Include *.cc -Exclude *_benchmark.cc,*benchmarks.cc,*_test.cc,*_testing.cc,*_test_*.cc,test_*.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filtersinternals +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClCompile>`r`n"
  $vcxprojinternals +=
      "    <ClCompile Include=`"$msvcrelativepath`">`r`n" +
      "       <ObjectFileName>`$(IntDir)internal/</ObjectFileName>`r`n" +
      "    </ClCompile>`r`n"
}
$filtersinternals += "  </ItemGroup>`r`n"
$vcxprojinternals += "  </ItemGroup>`r`n"

$dirfilterspath = [string]::format("{0}_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $dirfilterspath,
    $filtersheaders + $filtersinternals + $filterssources,
    [system.text.encoding]::utf8)

$benchmarksfilterspath = [string]::format("benchmarks_vcxproj_filters.txt", $dir)
Add-Content -Path $benchmarksfilterspath -Value $filtersbenchmarks -Encoding UTF8

$testsfilterspath = [string]::format("tests_vcxproj_filters.txt", $dir)
Add-Content -Path $testsfilterspath -Value $filterstests -Encoding UTF8

$dirvcxprojpath = [string]::format("{0}_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $dirvcxprojpath,
    $vcxprojheaders + $vcxprojinternals + $vcxprojsources,
    [system.text.encoding]::utf8)

$benchmarksvcxprojpath = [string]::format("benchmarks_vcxproj.txt", $dir)
Add-Content -Path $benchmarksvcxprojpath -Value $vcxprojbenchmarks -Encoding UTF8

$testsvcxprojpath = [string]::format("tests_vcxproj.txt", $dir)
Add-Content -Path $testsvcxprojpath -Value $vcxprojtests -Encoding UTF8
