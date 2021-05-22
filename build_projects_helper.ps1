# This script helps creating project files for abseil-cpp.  The argument is the path of a subdirectory of absl/.
# It produces three pairs of *.vcxproj, *.vcxproj.filters files: one for the subdirectory being operated upon,
# one for the benchmarks project and one for the tests project.  For the first pair, the generated XML may just
# be inserted at the right place in the project files, replacing whatever was there.  For the benchmarks and tests
# things are more complicate as the generated XML must be inserted at the right place.
# TODO(phl): The next time we do this dance, start by beefing up the script to generate the complete files for
# benchmarks and tests in one fell swoop.  That will save a lot of time and errors.

$dir = resolve-path $args[0]
$vcxprojname = [string]::format("{0}_vcxproj.txt", $dir)

$filtersheaders = "  <ItemGroup>`r`n"
$vcxprojheaders = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\*" -Include *.h | `
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
Get-ChildItem "$dir\*" -Include *.cc -Exclude *_benchmark.cc,*_test.cc,*_testing.cc,*_test_*.cc,test_*.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filterssources +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojsources +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filterssources += "  </ItemGroup>`r`n"
$vcxprojsources += "  </ItemGroup>`r`n"

$filtersbenchmarks = "  <ItemGroup>`r`n"
$vcxprojbenchmarks = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\*" -Recurse -Include *_benchmark.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filtersbenchmarks +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojbenchmarks +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filtersbenchmarks += "  </ItemGroup>`r`n"
$vcxprojbenchmarks += "  </ItemGroup>`r`n"

$filterstests = "  <ItemGroup>`r`n"
$vcxprojtests = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\*" -Recurse -Include *_testing.h,*_test_*.h,test_*.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
$vcxprojtests += "  </ItemGroup>`r`n"
$vcxprojtests += "  <ItemGroup>`r`n"
Get-ChildItem "$dir\*" -Recurse -Include *_test.cc,*_testing.cc,*_test_*.cc,test_*.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filterstests +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Source Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojtests +=
      "    <ClCompile Include=`"$msvcrelativepath`" />`r`n"
}
$filterstests += "  </ItemGroup>`r`n"
$vcxprojtests += "  </ItemGroup>`r`n"

$filtersinternals = "  <ItemGroup>`r`n"
$vcxprojinternals = "  <ItemGroup>`r`n"
Get-ChildItem "$dir\*\*" -Recurse -Include *.h -Exclude *_testing.h,*_test_*.h,test_*.h | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filtersinternals +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
  $vcxprojinternals +=
      "    <ClInclude Include=`"$msvcrelativepath`" />`r`n"
}
Get-ChildItem "$dir\*\*" -Recurse -Include *.cc -Exclude *_benchmark.cc,*_test.cc,*_testing.cc,*_test_*.cc,test_*.cc | `
Foreach-Object {
  $msvcrelativepath = $_.FullName -replace ".*abseil-cpp", "..\.."
  $filtersinternals +=
      "    <ClInclude Include=`"$msvcrelativepath`">`r`n" +
      "       <Filter>Internal Files</Filter>`r`n" +
      "    </ClInclude>`r`n"
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

$benchmarksfilterspath = [string]::format("{0}_benchmarks_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $benchmarksfilterspath,
    $filtersbenchmarks,
    [system.text.encoding]::utf8)

$testsfilterspath = [string]::format("{0}_tests_vcxproj_filters.txt", $dir)
[system.io.file]::writealltext(
    $testsfilterspath,
    $filterstests,
    [system.text.encoding]::utf8)

$dirvcxprojpath = [string]::format("{0}_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $dirvcxprojpath,
    $vcxprojheaders + $vcxprojinternals + $vcxprojsources,
    [system.text.encoding]::utf8)

$benchmarksvcxprojpath = [string]::format("{0}_benchmarks_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $benchmarksvcxprojpath,
    $vcxprojbenchmarks,
    [system.text.encoding]::utf8)

$testsvcxprojpath = [string]::format("{0}_tests_vcxproj.txt", $dir)
[system.io.file]::writealltext(
    $testsvcxprojpath,
    $vcxprojtests,
    [system.text.encoding]::utf8)
