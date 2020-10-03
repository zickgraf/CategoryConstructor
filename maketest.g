## This file is automatically generated by AutoDoc.
## Changes will be discarded by the next call of the AutoDoc method.


LoadPackage( "CategoryConstructor" );

LoadPackage( "IO_ForHomalg" );

HOMALG_IO.show_banners := false;

HOMALG_IO.suppress_PID := true;

HOMALG_IO.use_common_stream := true;

AUTODOC_file_scan_list := [ "../PackageInfo.g", "../examples/Example.g", "../examples/doc/doc.g", "../gap/CategoryConstructor.gd", "../gap/CategoryConstructor.gi", "../gap/Julia.gd", "../gap/Julia.gi", "../gap/Tools.gd", "../gap/Tools.gi", "../init.g", "../makedoc.g", "../maketest.g", "../read.g", "/Users/mo/software/pkg/CategoryConstructor/doc/_Chunks.xml" ];

LoadPackage( "GAPDoc" );

example_tree := ExtractExamples( Directory("./doc/"), "CategoryConstructor.xml", AUTODOC_file_scan_list, 500 );

RunExamples( example_tree, rec( compareFunction := "uptowhitespace" ) );

QUIT;