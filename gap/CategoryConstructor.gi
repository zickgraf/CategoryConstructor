#
# CategoryConstructor: Category constructor
#
# Implementations
#

##
SetInfoLevel( InfoCategoryConstructor, 1 );

##
InstallGlobalFunction( CategoryConstructor,
  function( )
    local name, CC, category_object_filter, category_morphism_filter, category_filter,
          commutative_ring, list_of_operations_to_install, skip, properties, doctrines, doc, prop,
          preinstall, func, is_monoidal, pos, create_func_bool, create_func_object0, create_func_morphism0,
          create_func_object, create_func_morphism, create_func_universal_morphism,
          create_func_list, create_func_object_or_fail,
          create_func_other_object, create_func_other_morphism,
          info, add;
    
    name := CAP_INTERNAL_RETURN_OPTION_OR_DEFAULT( "name", "new category" );
    
    CC := CreateCapCategory( name );
    
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
              "FiberProductEmbeddingInDirectSum", ## TOOD: CAP_INTERNAL_GET_CORRESPONDING_OUTPUT_OBJECTS in create_func_morphism cannot deal with it yet
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
    
    for name in list_of_operations_to_install do
        
        info := CAP_INTERNAL_METHOD_NAME_RECORD.(name);
        
        func := fail;
        
        if info.return_type = "bool" then
            if not IsFunction( create_func_bool ) then
                continue;
            fi;
            func := create_func_bool( name, CC );
        elif info.return_type = "object" and info.filter_list = [ "category" ] then
            if not IsFunction( create_func_object0 ) then
                continue;
            fi;
            func := create_func_object0( name, CC );
        elif info.return_type = "object" then
            if not IsFunction( create_func_object ) then
                continue;
            fi;
            func := create_func_object( name, CC );
        elif IsIdenticalObj( info.return_type, IsList ) then
            if not IsFunction( create_func_list ) then
                continue;
            fi;
            func := create_func_list( name, CC );
        elif info.return_type = "object_or_fail" then
            if not IsFunction( create_func_object_or_fail ) then
                continue;
            fi;
            func := create_func_object_or_fail( name, CC );
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
        elif info.return_type = "morphism" and info.filter_list = [ "category" ] then
            if not IsFunction( create_func_morphism0 ) then
                continue;
            fi;
            func := create_func_morphism0( name, CC );
        elif info.return_type = "morphism" or info.return_type = "morphism_or_fail" then
            if not IsBound( info.io_type ) then
                ## if there is no io_type we cannot do anything
                continue;
            elif IsList( info.with_given_without_given_name_pair ) and
              name = info.with_given_without_given_name_pair[1] then
                ## do not install universal morphisms but their
                ## with-given-universal-object counterpart
                if not info.with_given_without_given_name_pair[2] in list_of_operations_to_install then
                    Add( list_of_operations_to_install, info.with_given_without_given_name_pair[2] );
                fi;
                continue;
            elif IsBound( info.universal_object ) and
              Position( list_of_operations_to_install, info.universal_object ) = fail then
                ## add the corresponding universal object
                ## at the end of the list for its method to be installed
                Add( list_of_operations_to_install, info.universal_object );
            fi;
            
            if IsList( info.with_given_without_given_name_pair ) then
                if not IsFunction( create_func_universal_morphism ) then
                    continue;
                fi;
                func := create_func_universal_morphism( name, CC );
            else
                if not IsFunction( create_func_morphism ) then
                    continue;
                fi;
                func := create_func_morphism( name, CC );
            fi;
        else
            Info( InfoCategoryConstructor, 3, "cannot yet handle return_type=\"", info.return_type, "\" required for ", name );
            continue;
        fi;
        
        Info( InfoCategoryConstructor, 2, "Installing ", name );
        
        add := ValueGlobal( Concatenation( "Add", name ) );
        
        add( CC, func );
        
    od;
    
    return CC;
    
end );