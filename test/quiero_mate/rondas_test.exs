defmodule QuieroMate.RondasTest do
  use QuieroMate.DataCase

  alias QuieroMate.Rondas

  describe "rondas" do
    alias QuieroMate.Rondas.Ronda

    import QuieroMate.RondasFixtures

    @invalid_attrs %{rid: nil, creator: nil, users: nil}

    test "list_rondas/0 returns all rondas" do
      ronda = ronda_fixture()
      assert Rondas.list_rondas() == [ronda]
    end

    test "get_ronda!/1 returns the ronda with given id" do
      ronda = ronda_fixture()
      assert Rondas.get_ronda!(ronda.id) == ronda
    end

    test "create_ronda/1 with valid data creates a ronda" do
      valid_attrs = %{rid: 42, creator: "some creator", users: ["option1", "option2"]}

      assert {:ok, %Ronda{} = ronda} = Rondas.create_ronda(valid_attrs)
      assert ronda.rid == 42
      assert ronda.creator == "some creator"
      assert ronda.users == ["option1", "option2"]
    end

    test "create_ronda/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rondas.create_ronda(@invalid_attrs)
    end

    test "update_ronda/2 with valid data updates the ronda" do
      ronda = ronda_fixture()
      update_attrs = %{rid: 43, creator: "some updated creator", users: ["option1"]}

      assert {:ok, %Ronda{} = ronda} = Rondas.update_ronda(ronda, update_attrs)
      assert ronda.rid == 43
      assert ronda.creator == "some updated creator"
      assert ronda.users == ["option1"]
    end

    test "update_ronda/2 with invalid data returns error changeset" do
      ronda = ronda_fixture()
      assert {:error, %Ecto.Changeset{}} = Rondas.update_ronda(ronda, @invalid_attrs)
      assert ronda == Rondas.get_ronda!(ronda.id)
    end

    test "delete_ronda/1 deletes the ronda" do
      ronda = ronda_fixture()
      assert {:ok, %Ronda{}} = Rondas.delete_ronda(ronda)
      assert_raise Ecto.NoResultsError, fn -> Rondas.get_ronda!(ronda.id) end
    end

    test "change_ronda/1 returns a ronda changeset" do
      ronda = ronda_fixture()
      assert %Ecto.Changeset{} = Rondas.change_ronda(ronda)
    end
  end

  describe "rondas" do
    alias QuieroMate.Rondas.Ronda

    import QuieroMate.RondasFixtures

    @invalid_attrs %{cebador: nil, users: nil}

    test "list_rondas/0 returns all rondas" do
      ronda = ronda_fixture()
      assert Rondas.list_rondas() == [ronda]
    end

    test "get_ronda!/1 returns the ronda with given id" do
      ronda = ronda_fixture()
      assert Rondas.get_ronda!(ronda.id) == ronda
    end

    test "create_ronda/1 with valid data creates a ronda" do
      valid_attrs = %{cebador: "some cebador", users: ["option1", "option2"]}

      assert {:ok, %Ronda{} = ronda} = Rondas.create_ronda(valid_attrs)
      assert ronda.cebador == "some cebador"
      assert ronda.users == ["option1", "option2"]
    end

    test "create_ronda/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rondas.create_ronda(@invalid_attrs)
    end

    test "update_ronda/2 with valid data updates the ronda" do
      ronda = ronda_fixture()
      update_attrs = %{cebador: "some updated cebador", users: ["option1"]}

      assert {:ok, %Ronda{} = ronda} = Rondas.update_ronda(ronda, update_attrs)
      assert ronda.cebador == "some updated cebador"
      assert ronda.users == ["option1"]
    end

    test "update_ronda/2 with invalid data returns error changeset" do
      ronda = ronda_fixture()
      assert {:error, %Ecto.Changeset{}} = Rondas.update_ronda(ronda, @invalid_attrs)
      assert ronda == Rondas.get_ronda!(ronda.id)
    end

    test "delete_ronda/1 deletes the ronda" do
      ronda = ronda_fixture()
      assert {:ok, %Ronda{}} = Rondas.delete_ronda(ronda)
      assert_raise Ecto.NoResultsError, fn -> Rondas.get_ronda!(ronda.id) end
    end

    test "change_ronda/1 returns a ronda changeset" do
      ronda = ronda_fixture()
      assert %Ecto.Changeset{} = Rondas.change_ronda(ronda)
    end
  end
end
