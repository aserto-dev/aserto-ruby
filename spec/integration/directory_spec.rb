# frozen_string_literal: true

require_relative "topaz"

describe "Directory", type: :integration do
  # rubocop:disable RSpec/BeforeAfterAll
  before :all do
    Topaz.run
  end

  after :all do
    Topaz.cleanup
  end
  # rubocop:enable RSpec/BeforeAfterAll

  let :directory do
    Aserto::Directory::V3::Client.new(
      {
        url: "localhost:9292",
        cert_path: File.join(ENV.fetch("HOME", ""), ".config/topaz/certs/grpc-ca.crt")
      }
    )
  end

  let :manifest do
    <<~YAML
      # yaml-language-server: $schema=https://www.topaz.sh/schema/manifest.json
      ---

      ### filename: manifest.yaml ###
      ### datetime: 2023-10-17T00:00:00-00:00 ###
      ### description: acmecorp manifest ###

      ### model ###
      model:
        version: 3

      ### object type definitions ###
      types:
        ### display_name: User ###
        user:
          relations:
            ### display_name: user#manager ###
            manager: user

        ### display_name: Identity ###
        identity:
          relations:
            ### display_name: identity#identifier ###
            identifier: user

        ### display_name: Group ###
        group:
          relations:
            ### display_name: group#member ###
            member: user
    YAML
  end

  it "sets the manifest" do
    expect do
      directory.set_manifest(manifest)
    end.not_to raise_error
  end

  it "reads the manifest" do
    expect(directory.get_manifest.to_h[:body]).to eq(manifest)
  end

  it "creates a new object" do
    expect { directory.set_object(object_id: "my-user", object_type: "user") }.not_to raise_error
  end

  it "creates another object" do
    expect { directory.set_object(object_id: "my-group", object_type: "group") }.not_to raise_error
  end

  it "reads an object" do
    expect(directory.get_object(object_type: "user", object_id: "my-user").result.id).to eq("my-user")
  end

  it "reads another object" do
    expect(directory.get_object(object_type: "group", object_id: "my-group").result.id).to eq("my-group")
  end

  it "creates a relation between user and group" do
    expect do
      directory.set_relation(
        object_id: "my-user",
        object_type: "user",
        relation: "member",
        subject_id: "my-group",
        subject_type: "group"
      )
    end.not_to raise_error
  end

  it "reads a relation between user and group" do
    expect(directory.get_relation(
      object_id: "my-user",
      object_type: "user",
      relation: "member",
      subject_id: "my-group",
      subject_type: "group"
    ).result.to_h).to include(
      { object_type: "user",
        object_id: "my-user",
        relation: "member",
        subject_type: "group",
        subject_id: "my-group",
        subject_relation: "" }
    )
  end

  it "checks a relation between user and group" do
    expect(directory.check_relation(
      object_id: "my-user",
      object_type: "user",
      relation: "member",
      subject_id: "my-group",
      subject_type: "group"
    ).to_h).to eq(
      { check: false, trace: [] }
    )
  end

  it "checks a permission of an object" do
    expect(directory.check_permission(
      object_id: "my-user",
      object_type: "user",
      permission: "read",
      subject_id: "my-group",
      subject_type: "group"
    ).to_h).to eq(
      { check: false, trace: [] }
    )
  end

  it "lists the relations for a given object" do
    expect(directory.get_relations(
      object_id: "my-user",
      object_type: "user",
      relation: "member"
    ).results.map(&:to_h)[0]).to include(
      { object_type: "user",
        object_id: "my-user",
        relation: "member",
        subject_type: "group",
        subject_id: "my-group",
        subject_relation: "" }
    )
  end

  it "deletes a relation between user and group" do
    expect do
      directory.delete_relation(
        object_id: "my-user",
        object_type: "user",
        relation: "member",
        subject_id: "my-group",
        subject_type: "group"
      )
    end.not_to raise_error
  end

  it "raises error when getting a deleted relation" do
    expect do
      directory.get_relation(
        object_id: "my-user",
        object_type: "user",
        relation: "member",
        subject_id: "my-group",
        subject_type: "group"
      )
    end.to raise_error(GRPC::NotFound)
  end

  it "lists users objects" do
    expect(directory.get_objects(object_type: "user").results.length).to eq(1)
  end

  it "lists group objects" do
    expect(directory.get_objects(object_type: "group").results.length).to eq(1)
  end

  it "deletes an object" do
    expect { directory.delete_object(object_id: "my-user", object_type: "user") }.not_to raise_error
  end

  it "deletes another object" do
    expect { directory.delete_object(object_id: "my-group", object_type: "group") }.not_to raise_error
  end

  it "raises error when getting a deleted object" do
    expect do
      directory.get_object(
        object_type: "user",
        object_id: "my-user"
      )
    end.to raise_error(GRPC::NotFound)
  end

  it "raises error when getting another deleted object" do
    expect do
      directory.get_object(
        object_type: "group",
        object_id: "my-group"
      )
    end.to raise_error(GRPC::NotFound)
  end

  it "returns [] when there are no user objects" do
    expect(directory.get_objects(object_type: "user").results).to eq([])
  end

  it "returns [] when there are no group objects" do
    expect(directory.get_objects(object_type: "group").results).to eq([])
  end

  it "imports objects and relations" do
    expect do
      directory.import(
        [
          { object: { id: "import-user", type: "user" } },
          { object: { id: "import-group", type: "group" } },
          {
            relation: { object_id: "import-user", object_type: "user", relation: "member", subject_id: "import-group",
                        subject_type: "group" }
          }
        ]
      )
    end.not_to raise_error
  end

  it "exports objects" do
    expect(directory.export(data_type: :objects).length).to eq(2)
  end

  it "exports relations" do
    expect(directory.export(data_type: :relations).length).to eq(1)
  end

  it "exports all" do
    expect(directory.export(data_type: :all).length).to eq(3)
  end

  it "lists the new group objects" do
    expect(directory.get_objects(object_type: "group").results[0].to_h[:id]).to eq("import-group")
  end

  it "lists the new user objects" do
    expect(directory.get_objects(object_type: "user").results[0].to_h[:id]).to eq("import-user")
  end

  it "reads the relation with_objects" do
    expect(directory.get_relation(
      object_id: "import-user",
      object_type: "user",
      relation: "member",
      subject_id: "import-group",
      subject_type: "group",
      with_objects: true
    ).result.to_h).to include(
      { object_type: "user",
        object_id: "import-user",
        relation: "member",
        subject_type: "group",
        subject_id: "import-group",
        subject_relation: "" }
    )
  end

  it "deletes user object with relations" do
    expect do
      directory.delete_object(object_id: "import-user", object_type: "user", with_relations: true)
    end.not_to raise_error
  end

  it "deletes group object with relations" do
    expect do
      directory.delete_object(object_id: "import-group", object_type: "group", with_relations: true)
    end.not_to raise_error
  end

  it "raises error when getting a deleted object after import" do
    expect do
      directory.get_object(
        object_type: "user",
        object_id: "import-user"
      )
    end.to raise_error(GRPC::NotFound)
  end

  it "raises error when getting another deleted object after import" do
    expect do
      directory.get_object(
        object_type: "group",
        object_id: "import-group"
      )
    end.to raise_error(GRPC::NotFound)
  end

  it "raises error when getting a deleted relation after import" do
    expect do
      directory.get_relation(
        object_id: "import-user",
        object_type: "user",
        relation: "member",
        subject_id: "import-group",
        subject_type: "group"
      )
    end.to raise_error(GRPC::NotFound)
  end
end
