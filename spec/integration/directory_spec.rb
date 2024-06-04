# frozen_string_literal: true

describe "Directory", type: :integration do
  let :directory do
    Aserto::Directory::V3::Client.new(
      {
        url: "localhost:9292",
        cert_path: Topaz.cert_file,
        writer: {
          url: "localhost:9292"
        }
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
            member: user | group#member
          permissions:
            read: member

        # resource represents a protected resource
        resource:
          relations:
            owner: user
            writer: user | group#member
            reader: user | group#member

          permissions:
            can_read: reader | writer | owner
            can_write: writer | owner
            can_delete: owner
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
        subject_id: "my-user",
        subject_type: "user",
        relation: "member",
        object_id: "my-group",
        object_type: "group"
      )
    end.not_to raise_error
  end

  it "reads the graph between user and group" do
    expect(directory.get_graph(
      object_type: "group",
      object_id: "my-group",
      subject_type: "user",
      relation: "member"
    ).results.map(&:to_h)).to eq(
      [{ object_id: "my-user", object_type: "user" }]
    )
  end

  it "reads the graph explanation between user and group" do
    expect(directory.get_graph(
      object_type: "group",
      object_id: "my-group",
      subject_type: "user",
      relation: "member",
      explain: true
    ).explanation.to_h).to eq(
      { "user:my-user" => [["group:my-group#member@user:my-user"]] }
    )
  end

  it "reads a relation between user and group" do
    expect(directory.get_relation(
      subject_id: "my-user",
      subject_type: "user",
      relation: "member",
      object_id: "my-group",
      object_type: "group"
    ).result.to_h).to include(
      { subject_id: "my-user",
        subject_type: "user",
        relation: "member",
        object_id: "my-group",
        object_type: "group",
        subject_relation: "" }
    )
  end

  it "checks a relation between user and group" do
    expect(directory.check_relation(
      subject_id: "my-user",
      subject_type: "user",
      relation: "member",
      object_id: "my-group",
      object_type: "group"
    ).to_h).to eq(
      { check: true, trace: [] }
    )
  end

  it "checks an user and a group" do
    expect(directory.check(
      subject_id: "my-user",
      subject_type: "user",
      relation: "member",
      object_id: "my-group",
      object_type: "group"
    ).to_h).to eq(
      { check: true, trace: [] }
    )
  end

  it "checks a permission of an object" do
    expect(directory.check_permission(
      subject_id: "my-user",
      subject_type: "user",
      permission: "read",
      object_id: "my-group",
      object_type: "group"
    ).to_h).to eq(
      { check: true, trace: [] }
    )
  end

  it "lists the relations for a given object" do
    expect(directory.get_relations(
      subject_id: "my-user",
      subject_type: "user"
    ).results.map(&:to_h)[0]).to include(
      {
        subject_id: "my-user",
        subject_type: "user",
        relation: "member",
        object_id: "my-group",
        object_type: "group",
        subject_relation: ""
      }
    )
  end

  it "deletes a relation between user and group" do
    expect do
      directory.delete_relation(
        subject_id: "my-user",
        subject_type: "user",
        relation: "member",
        object_id: "my-group",
        object_type: "group"
      )
    end.not_to raise_error
  end

  it "raises error when getting a deleted relation" do
    expect do
      directory.get_relation(
        subject_id: "my-user",
        subject_type: "user",
        relation: "member",
        object_id: "my-group",
        object_type: "group"
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

          { op_code: 1, object: { id: "import-user", type: "user" } },
          { op_code: 1, object: { id: "import-group", type: "group" } },
          {
            op_code: 1,
            relation: {
              subject_id: "import-user",
              subject_type: "user",
              relation: "member",
              object_id: "import-group",
              object_type: "group"
            }
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
      subject_id: "import-user",
      subject_type: "user",
      relation: "member",
      object_id: "import-group",
      object_type: "group",
      with_objects: true
    ).objects.length).to eq(2)
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
        subject_id: "import-user",
        subject_type: "user",
        relation: "member",
        object_id: "import-group",
        object_type: "group"
      )
    end.to raise_error(GRPC::NotFound)
  end

  it "creates a resource object" do
    expect { directory.set_object(object_id: "resource", object_type: "resource") }.not_to raise_error
  end

  it "creates a group object" do
    expect { directory.set_object(object_id: "admin", object_type: "group") }.not_to raise_error
  end

  it "creates a relation(subject) between a group and a resource" do
    expect do
      directory.set_relation(
        object_type: "resource",
        object_id: "resource",
        relation: "writer",
        subject_type: "group",
        subject_id: "admin",
        subject_relation: "member"
      )
    end.not_to raise_error
  end
end
