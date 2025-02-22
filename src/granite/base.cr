require "./collection"
require "./association_collection"
require "./associations"
require "./callbacks"
require "./columns"
require "./query/executors/base"
require "./query/**"
require "./settings"
require "./table"
require "./validators"
require "./validation_helpers/**"
require "./migrator"
require "./select"
require "./version"
require "./connections"
require "./integrators"
require "./converters"
require "./type"
require "./connection_management"

# Granite::Base is the base class for your model objects.
abstract class Granite::Base
  include Associations
  include Callbacks
  include Columns
  include Tables
  include Transactions
  include Validators
  include ValidationHelpers
  include Migrator
  include Select

  include ConnectionManagement

  extend Columns::ClassMethods
  extend Tables::ClassMethods
  extend Granite::Migrator::ClassMethods

  extend Querying
  extend Query::BuilderMethods
  extend Transactions::ClassMethods
  extend Integrators
  extend Select

  macro inherited
    protected class_getter select_container : Container = Container.new(table_name: table_name, fields: fields)

    include JSON::Serializable
    include YAML::Serializable

    # Returns true if this object hasn't been saved yet.
    @[JSON::Field(ignore: true)]
    @[YAML::Field(ignore: true)]
    disable_granite_docs? property? new_record : Bool = true

    # Returns true if this object has been destroyed.
    @[JSON::Field(ignore: true)]
    @[YAML::Field(ignore: true)]
    disable_granite_docs? getter? destroyed : Bool = false

    # Returns true if the record is persisted.
    disable_granite_docs? def persisted?
      !(new_record? || destroyed?)
    end

    disable_granite_docs? def initialize(**args : Granite::Columns::Type)
      set_attributes(args.to_h.transform_keys(&.to_s))
    end

    disable_granite_docs? def initialize(args : Granite::ModelArgs)
      set_attributes(args.transform_keys(&.to_s))
    end

    disable_granite_docs? def initialize
    end

    before_save :switch_to_writer_adapter
    before_destroy :switch_to_writer_adapter
    after_save :update_last_write_time
    after_save :schedule_adapter_switch
    after_destroy :update_last_write_time
    after_destroy :schedule_adapter_switch
  end
end
