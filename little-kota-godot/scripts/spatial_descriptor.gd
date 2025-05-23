extends Marker3D
class_name SpatialDescriptor

enum SpaceTypes {
	OBJECT,
	AREA,
	ENTITY
}

@export var space_type : SpaceTypes
@export var space_name : String
@export var space_description : String

func _ready():
	add_to_group("spatial_descriptors")
