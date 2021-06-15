# SPDX-License-Identifier: GPL-2.0-or-later
# CategoryConstructor: Construct categories out of given ones
#
# Implementations
#

##
SetInfoLevel( InfoCategoryConstructor, 1 );

## recursion method
InstallMethod( UnderlyingCell,
        "for a list",
        [ IsList ],
        
  function( L )
    
    return List( L, UnderlyingCell );
    
end );

## the identity on integers
InstallMethod( UnderlyingCell,
        "for an integer",
        [ IsInt ],
        
  IdFunc );

##
InstallGlobalFunction( CategoryConstructor,
  function( )
    local name, CC, category_object_filter, category_morphism_filter, category_filter,
          commutative_ring, list_of_operations_to_install, skip, properties, doctrines, doc, prop,
          preinstall, func, is_monoidal, pos, create_func_bool, create_func_object0, create_func_morphism0,
          create_func_object, create_func_morphism, create_func_morphism_or_fail, create_func_universal_morphism,
          create_func_list, create_func_object_or_fail,
          create_func_other_object, create_func_other_morphism,
          print, info, with_given_object_name, add,
          underlying_arguments, underlying_category_getter_string, underlying_object_getter_string, underlying_morphism_getter_string;
    
    name := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "name", "new category" );
    
    CC := CreateCapCategory( name );
    
    if IsIdenticalObj( CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "category_as_first_argument", false ), true ) then
        CC!.category_as_first_argument := true;
    fi;
    
    category_object_filter := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "category_object_filter", IsCapCategoryObject );
    category_morphism_filter := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "category_morphism_filter", IsCapCategoryMorphism );
    
    AddObjectRepresentation( CC, category_object_filter );
    AddMorphismRepresentation( CC, category_morphism_filter );
    
    category_filter := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "category_filter", fail );
    
    if not category_filter = fail then
        SetFilterObj( CC, category_filter );
    fi;
    
    commutative_ring := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "commutative_ring", fail );
    
    if not commutative_ring = fail then
        SetCommutativeRingOfLinearCategory( CC, commutative_ring );
    fi;
    
    list_of_operations_to_install := SortedList( RecNames( CAP_INTERNAL_METHOD_NAME_RECORD ) );
    
    list_of_operations_to_install := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "list_of_operations_to_install", list_of_operations_to_install );
    
    list_of_operations_to_install := ShallowCopy( list_of_operations_to_install );
    
    skip := [ 
              "IsIdenticalToIdentityMorphism",    ## the CAP specification depends on IsEqualForMorphisms which might be different in the resulting category
              "IsIdenticalToZeroMorphism",        ## the CAP specification depends on IsEqualForMorphisms which might be different in the resulting category
              "DirectSumCodiagonalDifference",    ## TOOD: CAP_INTERNAL_GET_CORRESPONDING_OUTPUT_OBJECTS in create_func_morphism cannot deal with it yet
              "DirectSumDiagonalDifference",      ## TOOD: CAP_INTERNAL_GET_CORRESPONDING_OUTPUT_OBJECTS in create_func_morphism cannot deal with it yet
              "FiberProductEmbeddingInDirectSum", ## TOOD: CAP_INTERNAL_GET_CORRESPONDING_OUTPUT_OBJECTS in create_func_morphism cannot deal with it yet
              "MorphismBetweenDirectSumsWithGivenDirectSums", # lists of lists of morphisms
              "ObjectConstructor",
              "MorphismConstructor",
              "HomologyObjectFunctorialWithGivenHomologyObjects",
              "IsCodominating",
              "IsDominating",
              "IsEqualAsFactorobjects",
              "IsEqualAsSubobjects",
              "UniversalMorphismFromImageWithGivenImageObject",
              "UniversalMorphismIntoCoimageWithGivenCoimage",
              "UniversalMorphismFromImage",
              "UniversalMorphismIntoCoimage",
              ];
    
    properties := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "properties", [ ] );
    
    doctrines := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "doctrines", [ ] );
    
    if not doctrines = [ ] and IsStringRep( doctrines ) then
        doctrines := [ doctrines ];
    fi;
    
    for doc in properties do
        if IsList( doc ) and Length( doc ) = 2 and IsBool( doc[2] ) then
            prop := doc[1];
        else
            prop := doc;
        fi;
        if not ForAny( doctrines, doc -> ( IsList( doc ) and Length( doc ) = 2 and IsBool( doc[2] ) and doc[1] = prop ) or doc = prop ) then
            Add( doctrines, doc );
        fi;
    od;
    
    if not ForAll( doctrines, doc -> IsList( doc ) and Length( doc ) = 2 and IsBool( doc[2] ) or IsStringRep( doc ) ) then
        Error( "the list of doctrines  ", doctrines, " has a wrong syntax, it should be something like [ [ \"doc1\", bool1 ], \"doc2\", [ \"doc3\", bool3 ] ]\n" );
    fi;
    
    for doc in doctrines do
        if IsList( doc ) and Length( doc ) = 2 and IsBool( doc[2] ) then
            name := doc[1];
            doc := doc[2];
        else
            name := doc;
            doc := true;
        fi;
        
        name := ValueGlobal( name );
        
        Setter( name )( CC, doc );
        
    od;
    
    preinstall := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "preinstall", [ ] );
    
    if IsFunction( preinstall ) then
        preinstall := [ preinstall ];
    fi;
    
    for func in preinstall do
        func( CC );
    od;
    
    is_monoidal := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "is_monoidal", false );
    
    if is_monoidal = false then
        Append( skip, NamesOfComponents( MONOIDAL_CATEGORIES_BASIC_METHOD_NAME_RECORD ) );
        Append( skip, NamesOfComponents( MONOIDAL_CATEGORIES_METHOD_NAME_RECORD ) );
        Append( skip, NamesOfComponents( DISTRIBUTIVE_MONOIDAL_CATEGORIES_METHOD_NAME_RECORD ) );
        Append( skip, NamesOfComponents( BRAIDED_MONOIDAL_CATEGORIES_METHOD_NAME_RECORD ) );
        Append( skip, NamesOfComponents( CLOSED_MONOIDAL_CATEGORIES_METHOD_NAME_RECORD ) );
        Append( skip, NamesOfComponents( RIGID_SYMMETRIC_CLOSED_MONOIDAL_CATEGORIES_METHOD_NAME_RECORD ) );
    fi;
    
    for func in skip do
        
        pos := Position( list_of_operations_to_install, func );
        if not pos = fail then
            Remove( list_of_operations_to_install, pos );
        fi;
        
    od;
    
    for func in skip do
        
        pos := Position( list_of_operations_to_install, func );
        if not pos = fail then
            Remove( list_of_operations_to_install, pos );
        fi;
        
    od;
    
    ## e.g., IsMonomorphism
    create_func_bool := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_bool", fail );
    
    ## e.g., ZeroObject
    create_func_object0 := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_object0", fail );
    
    ## e.g., ZeroObjectFunctorial
    create_func_morphism0 := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_morphism0", fail );
    
    ## e.g., DirectSum
    create_func_object := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_object", fail );
    
    ## e.g., IdentityMorphism, PreCompose
    create_func_morphism := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_morphism", fail );
    
    ## e.g., Lift
    create_func_morphism_or_fail := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_morphism_or_fail", fail );
    
    ## e.g., CokernelColiftWithGivenCokernelObject
    create_func_universal_morphism := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_universal_morphism", fail );
    
    ##
    create_func_list := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_list", fail );
    
    ##
    create_func_object_or_fail := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_object_or_fail", fail );
    
    ##
    create_func_other_object := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_other_object", fail );
    
    ##
    create_func_other_morphism := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "create_func_other_morphism", fail );
    
    ##
    underlying_category_getter_string := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "underlying_category_getter_string", fail );
    underlying_object_getter_string := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "underlying_object_getter_string", fail );
    underlying_morphism_getter_string := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "underlying_morphism_getter_string", fail );
    
    ##
    print := IsIdenticalObj( CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "print", false ), true );
    
    # deprecate create_func_object0 and create_func_morphism0 if category_as_first_argument is set
    if ValueOption( "category_as_first_argument" ) = true and create_func_object0 <> fail then
        
        Display( "WARNING: category_as_first_argument is set to true, so create_func_object will be used instead of create_func_object0. Adjust create_func_object and remove create_func_object0 to prevent this warning." );
        
    fi;
    
    if ValueOption( "category_as_first_argument" ) = true and create_func_morphism0 <> fail then
        
        Display( "WARNING: category_as_first_argument is set to true, so create_func_morphism will be used instead of create_func_morphism0. Adjust create_func_morphism and remove create_func_morphism0 to prevent this warning." );
        
    fi;
    
    # set default values
    if create_func_morphism_or_fail = fail then
        
        create_func_morphism_or_fail := create_func_morphism;
        
    fi;
    
    if create_func_universal_morphism = fail then
        
        create_func_universal_morphism := create_func_morphism;
        
    fi;
    
    Info( InfoCategoryConstructor, 2,  "Lifting the following operations for ", Name( CC ), ":\n" );
    
    if print then
        print := Name( CC );
        Print( "Lifting the following operations for ", print, ":\n\n" );
    fi;
    
    #Display( list_of_operations_to_install );
    
    for name in list_of_operations_to_install do
        
        info := CAP_INTERNAL_METHOD_NAME_RECORD.(name);
        
        if ValueOption( "category_as_first_argument" ) = true then
            
            if info.filter_list[1] <> "category" then
                
                Display( Concatenation(
                    "WARNING: If the option category_as_first_argument is set to true, category contructor cannot deal with operations which do not get the category as the first argument. ",
                    "The installation of ", name, " will be skipped. ",
                    "To get rid of this warning, add \"category\" as the first entry of `filter_list` in the corresponding method record entry. ",
                    "For more information about the implications of doing so, search for `filter_list` in the documentation of CAP."
                ) );
                continue;
                
            fi;
            
        fi;
        
        func := fail;
        
        if info.return_type = "bool" then
            if IsFunction( create_func_bool ) then
                func := create_func_bool( name, CC );
            elif create_func_bool = "default" then
                func := """
                    function( input_arguments )
                        
                        return operation_name( underlying_arguments );
                        
                    end
                """;
            else
                continue;
            fi;
        elif ValueOption( "category_as_first_argument" ) <> true and info.return_type = "object" and info.filter_list = [ "category" ] then
            if not IsFunction( create_func_object0 ) then
                continue;
            fi;
            func := create_func_object0( name, CC );
        elif info.return_type = "object" then
            if IsFunction( create_func_object ) then
                func := create_func_object( name, CC );
            elif create_func_object = "default" then
                func := """
                    function( input_arguments )
                        local result;
                        
                        result := operation_name( underlying_arguments );
                        
                        return ObjectConstructor( cat, result );
                        
                    end
                """;
            else
                continue;
            fi;
        elif IsIdenticalObj( info.return_type, IsList ) then
            if not IsFunction( create_func_list ) then
                continue;
            fi;
            func := create_func_list( name, CC );
        elif info.return_type = "object_or_fail" then
            if IsFunction( create_func_object_or_fail ) then
                func := create_func_object_or_fail( name, CC );
            elif create_func_object_or_fail = "default" then
                func := """
                    function( input_arguments )
                        local result;
                        
                        result := operation_name( underlying_arguments );
                        
                        if result = fail then
                            
                            return fail;
                            
                        else
                            
                            return ObjectConstructor( cat, result );
                            
                        fi;
                        
                    end
                """;
            else
                continue;
            fi;
        elif info.return_type = "other_object" then
            if not IsFunction( create_func_other_object ) then
                continue;
            fi;
            func := create_func_other_object( name, CC );
        elif info.return_type = "other_morphism" then
            if not IsFunction( create_func_other_morphism ) then
                continue;
            fi;
            func := create_func_other_morphism( name, CC );
        elif ValueOption( "category_as_first_argument" ) <> true and info.return_type = "morphism" and info.filter_list = [ "category" ] then
            if not IsFunction( create_func_morphism0 ) then
                continue;
            fi;
            func := create_func_morphism0( name, CC );
        elif info.return_type = "morphism_or_fail" then
            if not IsBound( info.io_type ) then
                ## if there is no io_type we cannot do anything
                continue;
            fi;
            if IsFunction( create_func_morphism_or_fail ) then
                func := create_func_morphism_or_fail( name, CC );
            elif create_func_morphism_or_fail = "default" then
                func := """
                    function( input_arguments )
                        local result;
                        
                        result := operation_name( underlying_arguments );
                        
                        if result = fail then
                            
                            return fail;
                            
                        else
                            
                            return MorphismConstructor( cat, top_source, result, top_range );
                            
                        fi;
                        
                    end
                """;
            else
                continue;
            fi;
        elif info.return_type = "morphism" then
            if not IsBound( info.io_type ) then
                ## if there is no io_type we cannot do anything
                continue;
            elif IsList( info.with_given_without_given_name_pair ) and
              name = info.with_given_without_given_name_pair[1] then
                ## do not install universal morphisms but their
                ## with-given-universal-object counterpart and the universal object
                if not info.with_given_without_given_name_pair[2] in list_of_operations_to_install then
                    Add( list_of_operations_to_install, info.with_given_without_given_name_pair[2] );
                fi;
                with_given_object_name := CAP_INTERNAL_METHOD_NAME_RECORD.(info.with_given_without_given_name_pair[2]).with_given_object_name;
                if not with_given_object_name in list_of_operations_to_install then
                    Add( list_of_operations_to_install, with_given_object_name );
                fi;
                continue;
            fi;
            
            if IsList( info.with_given_without_given_name_pair ) then
                if IsFunction( create_func_universal_morphism ) then
                    func := create_func_universal_morphism( name, CC );
                elif create_func_universal_morphism = "default" then
                    func := """
                        function( input_arguments )
                            local result;
                            
                            result := operation_name( underlying_arguments );
                            
                            return MorphismConstructor( cat, top_source, result, top_range );
                            
                        end
                    """;
                else
                    continue;
                fi;
            else
                if IsFunction( create_func_morphism ) then
                    func := create_func_morphism( name, CC );
                elif create_func_morphism = "default" then
                    func := """
                        function( input_arguments )
                            local result;
                            
                            result := operation_name( underlying_arguments );
                            
                            return MorphismConstructor( cat, top_source, result, top_range );
                            
                        end
                    """;
                else
                    continue;
                fi;
            fi;
        else
            Info( InfoCategoryConstructor, 3, "cannot yet handle return_type=\"", info.return_type, "\" required for ", name );
            continue;
        fi;
        
        Info( InfoCategoryConstructor, 2, name );
        
        if IsString( print ) then
            Display( name );
        fi;
        
        add := ValueGlobal( Concatenation( "Add", name ) );
        
        if IsString( func ) then
            #Display( func );
            
            func := ReplacedString( func, "operation_name", name );
            func := ReplacedString( func, "input_arguments", JoinStringsWithSeparator( info.input_arguments_names, ", " ) );
            
            if underlying_category_getter_string <> fail and underlying_object_getter_string <> fail and underlying_morphism_getter_string <> fail then
                
                underlying_arguments := List( [ 1 .. Length( info.filter_list ) ], function( i )
                  local filter, argument_name;
                    
                    filter := info.filter_list[i];
                    argument_name := info.input_arguments_names[i];
                    
                    if filter = "category" then
                        
                        return Concatenation( underlying_category_getter_string, "( ", argument_name, " )" );
                        
                    elif filter = "object" then
                        
                        return Concatenation( underlying_object_getter_string, "( cat, ", argument_name, " )" );
                        
                    elif filter = "morphism" then
                        
                        return Concatenation( underlying_morphism_getter_string, "( cat, ", argument_name, " )" );
                        
                    elif filter = IsInt or filter = IsRingElement or filter = IsCyclotomic then
                        
                        return argument_name;
                        
                    elif filter = "list_of_objects" then
                        
                        return Concatenation( "List( ", argument_name, ", x -> ObjectDatum( cat, x ) )" );
                        
                    elif filter = "list_of_morphisms" then
                        
                        return Concatenation( "List( ", argument_name, ", x -> MorphismDatum( cat, x ) )" );
                        
                    else
                        
                        Error( "this case is not handled yet" );
                        
                    fi;
                    
                end );
                
                func := ReplacedString( func, "underlying_arguments", JoinStringsWithSeparator( underlying_arguments, ", " ) );
                
            elif PositionSublist( func, "underlying_arguments" ) <> fail then
                
                Error( "for generating underlying_arguments you must pass category, object and morphism getter strings" );
                
            fi;
            
            if IsBound( info.output_source_getter_string ) then
                
                func := ReplacedString( func, "top_source", info.output_source_getter_string );
                
            fi;
            
            if IsBound( info.output_range_getter_string ) then
                
                func := ReplacedString( func, "top_range", info.output_range_getter_string );
                
            fi;
            
            if PositionSublist( func, "top_source" ) <> fail or PositionSublist( func, "top_range" ) <> fail then
                
                continue;
                Display( name );
                Display( func );
                Error();
                
            fi;
            
            #Display( name );
            #Display( func );
            
            func := EvalString( func );
            
        fi;
        
        add( CC, func );
        
    od;
    
    Info( InfoCategoryConstructor, 2, "" );
    
    if IsString( print ) then
        Display( "" );
    fi;
    
    return CC;
    
end );
