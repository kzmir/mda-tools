#!/usr/bin/perl -w
package DataFile::LookupData;

use strict;
use utf8;
use Data::Dumper;
use Tools;
use Log::Log4perl qw(:easy);
use Module::Find;

# TODO: targetElement and type properties has been removed from XSD of the
# dataFile, some checks should be made and these attributes should be removed 
# from this class

# Constructor method, by default, takes the same params as DataSource object
sub new {
	my $class    = shift;
	my $params;
	
	if(@_) {
		$params = shift();
	}
	
	my $lookup = {};

	bless( $lookup, $class );

	# if there's params and if this param is a hash
	if(ref($params) eq 'HASH') {
		if ( defined( $params->{version} ) ) {
			$lookup->version( $params->{version} );
		}
		if ( defined( $params->{name} ) ) {
			$lookup->name( $params->{name} );
		}
		if ( defined( $params->{providerName} ) ) {
			$lookup->providerName( $params->{providerName} );
		}
#		if ( defined( $params{reader} ) ) {
#			$dataSource->reader( $params{reader} );
#		}
		if ( defined( $params->{providerUrl} ) ) {
			$lookup->providerUrl( $params->{providerUrl} );
		}
	}
	elsif(ref($params) ne 'HASH') {
		ERROR("Constructor params must be a hash");
	}
	return $lookup;
}

# class element accessor
# sets the class element or return it
sub class {
	my $self = shift;
	my $class   = shift;
	
	if (defined($class)) 
	{ 
		$self->{class} = Tools::trim($class) 
	}
	return $self->{class};
}

# name element accessor, returns or set name
sub name {
	my $selforClassname = shift;
	my $name   = shift;
	if(not ref($selforClassname)) # param isn't a reference, must be a static call
	{ # if  $self is not a reference, it must be a class (class access)
		my $varName = $selforClassname.'::DataSourceName';
		no strict "refs"; 	
		return $$varName;
	}
	if ($name) { $selforClassname->{name} = Tools::trim($name) }
	return $selforClassname->{name};
}

# version element accessor, returns or set version
sub version {
	my $self = shift;
	my $version   = shift;
	if ($version) { $self->{version} = Tools::trim($version) }
	return $self->{version};
}

# providerUrl element accessor, returns or set providerUrl
sub providerUrl {
	my $selforClassname = shift;
	my $providerUrl   = shift;

	if(not ref($selforClassname)) # param isn't a reference, must be a static call
	{ # if  $self is not a reference, it must be a class (class access)
		my $varName = $selforClassname.'::providerUrl';
		no strict "refs"; 	
		return $$varName;
	}
	
	if ($providerUrl) { $selforClassname->{providerUrl} = Tools::trim($providerUrl) }
	return $selforClassname->{providerUrl};
}

# providerName element accessor, returns or set providerName
sub providerName {
	my $selforClassname = shift;
	my $providerName   = shift;

	if(not ref($selforClassname)) # param isn't a reference, must be a static call
	{ # if  $self is not a reference, it must be a class (class access)
		my $varName = $selforClassname.'::providerName';
		no strict "refs"; 	
		return $$varName;
	}

	if ($providerName) { $selforClassname->{providerName} = Tools::trim($providerName) }

	return $selforClassname->{providerName};
}

# Static or instance call, returns an array of available dataSources
# modules
sub availableDataSourcesLookups{
	my @dataSourcesLookupModules;
	foreach my $myModule(findallmod DataSource) {
		if($myModule =~ /.*Lookup/ ) {
			eval("use $myModule");
			push @dataSourcesLookupModules, $myModule;
		}
	}
	return @dataSourcesLookupModules;
}

# Returns an array of all supported LookupItems
# takes two params, one is the criteria name, the 
# other is the criteria value
# $lookup->getSupportedLookupItemsByCriteriaAndValue( 'targetElement', 'album')
sub getSupportedLookupItemsByCriteriaAndValue {
	my $selfOrClass = shift;
	return($selfOrClass->getItemsByCriteriaAndValue(@_, $selfOrClass->supportedLookupItems() ) );
}

# Returns an array of all supported LookupItems 
# takes a hash ref of itemProperty => propertyValue
# $lookup->getSupportedLookupItemsByCriteriasAndValuesHashRef( 
#                     {targetElement => 'album', type => 'retrieval'} )
sub getSupportedLookupItemsByCriteriasAndValuesHashRef {
	my $selfOrClass = shift;
	return($selfOrClass->getItemsByCriteriasAndValuesHashRef (@_, $selfOrClass->supportedLookupItems() ) );	
}

# Returns an array of all LookupItems set in the lookupData
# takes two params, one is the criteria name, the 
# other is the criteria value
# $lookup->getSupportedLookupItemsByCriteriaAndValue( 'targetElement', 'album')
sub getLookupItemsByCriteriaAndValue {
	my $self = shift;
	return($self->getItemsByCriteriaAndValue(@_, $self->lookupItems() ) );
}

# Returns an array of all LookupItems in the lookupData 
# takes a hash ref of itemProperty => propertyValue
sub getLookupItemsByCriteriasAndValuesHashRef {
	my $self = shift;
	return($self->getItemsByCriteriasAndValuesHashRef(@_, $self->lookupItems() ) );
}

# Returns LookupItems known by the lookupData
sub supportedLookupItems {
	my $selforClassname = shift;	# XXX: ignore calling class/object
	my $varName;

	if(ref($selforClassname)) { # param is a reference, trying "access by instance"
		$varName = ref($selforClassname).'::supportedLookupItems';
	} 
	else 
	{ # if  $self is not a reference, it must be a class (class access)
		$varName = $selforClassname.'::supportedLookupItems';
	}

	no strict "refs"; 	
	return $$varName;
}

# Accessor for lookupItems
# if the
sub lookupItems {
	my $self = shift;
	my $lookupItems = shift;

	# if no array ref is sent
	if(!$lookupItems) {
		# if no performances array exists
		if(ref($self->{lookupItems}{lookupItem}) ne 'ARRAY') {
			#create it
			$self->{lookupItems}{lookupItem}=[];
			DEBUG 'Initializing lookupItems array'
		} # returning existing or initialized
		return ($self->{lookupItems}{lookupItem});
	}
	if($#$lookupItems == -1) {
		DEBUG "called LookupData->lookupItems with an empty array, truncating!";
		$self->{lookupItems}{lookupItem}=[];
	}
	$self->{lookupItems}{lookupItem} = $lookupItems;
	return($self->{lookupItems}{lookupItem});
}

# Generic method for finding lookupItems
# takes criteria, value and the items array in parameters
sub getItemsByCriteriaAndValue {
	my $self = shift;	# XXX: ignore calling class/object
	my $criteria = shift;
	my $value = shift;
	my $lookupItems = shift;
	my $foundItems = undef;

	# for each item in the items array
	foreach my $item (@{$lookupItems }) {
		# if the criteria existis in the current item and is the same 
		# as the value in the parameter
		if(exists($item->{$criteria}) and $item->{$criteria} eq $value ) {
			# add this lookupItem to the list of items to be returned
			push @{$foundItems}, $item;
		}
	}
	return $foundItems;
}

# Generic method for finding lookupItems
# takes a criteris/values hashRef and the itemHashRef in parameters
sub getItemsByCriteriasAndValuesHashRef {
	my $self = shift;	# XXX: ignore calling class/object
	my $criteriaAndValueHashRef = shift;
	my $items = shift;
	my $foundItems = undef;

	# for each item in the items array
	foreach my $item (@{$items}) {
		# the loop discards non matching items
		my $paramMatch = 1;
		
		# for each criteria the caller wants a check
		foreach my $criteria (keys(%{$criteriaAndValueHashRef})) {
			# if the item criteria/value doesn't match
			if(not (exists($item->{$criteria}) and $item->{$criteria} eq $criteriaAndValueHashRef->{$criteria} )) {
				$paramMatch=0;
				last; # no need to test another criteria
			}
		}
		if($paramMatch) {
			push @{$foundItems}, $item;
		}
	}
	return $foundItems;
}

# add a lookupItem (hashRef) in the array, returns an error
# if the item already exists
sub addLookupItem {
	my $self = shift;
	my $item = shift; 

	my $foundItems = $self->getLookupItemsByCriteriaAndValue('name', $item->{name});
	if(defined ($foundItems)) {
		ERROR("Item already exists");
		return undef;
	}
	else {
		push @{$self->{lookupItems}{lookupItem}}, $item;
	}
	return $item;
}

# Set the value of an item given its name
# if the item exists, it's update, if it doesn't exist
# the item is created from the "supporter items" template
sub setLookupItemByName {
	my $self = shift;
	my $paramName = shift;
	my $paramValue = shift;
	my $foundItems= undef;
	my $itemToSet = undef;
	
	# find possible already existing item with this name
	$foundItems = $self->getLookupItemsByCriteriaAndValue('name', $paramName);
	
	# the item doesn't exists
	if(!defined ($foundItems)) {
		# look for a supported item with this name
		$foundItems = $self->getSupportedLookupItemsByCriteriaAndValue('name', $paramName);

		# item not defined as supported item, can't do anything!
		if(!defined ($foundItems)) {
			ERROR("unknown lookup item $paramName");
			return 0;
		}

		# if more than one item is returned, that's also an error (shouldn't happen)
		if(scalar(@{$foundItems} !=1 )) {
			ERROR("found several items with name $paramName");
			return 0;
		}
		

	# Old version, where all item properties was copied (and serialized)
		# copy the returned supported item in a new element
		# my %newItem = %{$foundItems->[0]};
	# It seems like a better idea to just use name/value and keep details in lookup data
		my %newItem = ( 'name', $paramName);
		# and add it to the item in the LookupData
		$self->addLookupItem(\%newItem);
		$itemToSet = \%newItem;
	} 
	# the item is found in existing item, so we just have to update it
	else {
		$itemToSet = $foundItems->[0];
	}
	
	# update item value from its name
	$itemToSet->{value} = $paramValue;
	return 1;
}

sub albumFile {
	my $self = shift;
	my $albumFile = shift;
	
	# If there's no parameter in the input, it's a GET
	unless($albumFile) {
		#if there is already an object
		if (ref($self->{-albumFile}) eq 'DataFile::AlbumFile') {
			# return It
			return $self->{-albumFile};
		}else { # create a new empty object of this type
			$self->{-albumFile}= DataFile::AlbumFile->new();
		}
	}
	# There's a parameter in input, it's a SET
	if (ref($albumFile) eq 'DataFile::AlbumFile') { 
		$self->{-albumFile}= $albumFile; 
	}
	elsif($albumFile){  # We only insert objects of the good type
		ERROR('Object ->-albumFile called with an unexpected parameter '.ref($albumFile).' waiting a DataFile::AlbumFile');
	}
	# Return the set object
	return $self->{-albumFile};
}

sub deserialize{
	my $self = shift or return undef;
	
	if(exists($self->{lookupItems}) and exists($self->{lookupItems}{lookupItem}) ) {
		unless(ref($self->{lookupItems}{lookupItem}) eq 'ARRAY') {
			my $lookupItemsArray=$self->{lookupItems}{lookupItem};
			push @{$self->{lookupItems}{lookupItem}=[]}, $lookupItemsArray;
		}
	}
}

#sub lookupData {
#	my $self = shift or return undef;
#	my $lookupDataName = shift or return undef; 
#
#	# DataSource must have it's providerName filled for coherency check
#	unless( $self and $lookupDataName ) { 
#		ERROR("Missing lookup data name"); 
#		return undef; 
#	}
#	
#	# foreach dataSource in this albumfile, look for an already existing dataSource with the same name
#	foreach my $existingLookupData ( @{$self->{lookupDatas}{lookupData}} ) {
#		if($existingLookupData->name() eq $lookupDataName) {
#			return $existingDataSource;
#		}
#	}
# 
#	WARN("Lookupdata $lookupDataName not found");
#	return undef;
#}
#
#sub lookupDatas  {
#	my $self = shift;
#	my $lookupDatas = shift;
#	
#	# if no performances array ref is sent
#	if(!$lookupDatas) {
#		
#		# if no performances array exists
#		if(ref($self->{lookupDatas}{lookupData}) ne 'ARRAY') {
#			#create it
#			$self->{lookupDatas}{lookupData}=[];
#			DEBUG 'Initializing normalized date array'
#		} # returning existing or initialized
#		
#		return ($self->{lookupDatas}{lookupData});
#	}
#	
#	if($#$lookupDatas == -1) {
#		DEBUG "called AlbumFile->$lookupDatas with an empty array, truncating!";
#	}
#	
#	$self->{lookupDatas}{lookupData} = $lookupDatas;
#}


1;