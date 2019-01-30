#
# This file is part of Astarte.
#
# Copyright 2017 Ispirata Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule Astarte.Housekeeping.APIWeb.RealmController do
  use Astarte.Housekeeping.APIWeb, :controller

  alias Astarte.Housekeeping.API.Realms
  alias Astarte.Housekeeping.API.Realms.Realm

  action_fallback Astarte.Housekeeping.APIWeb.FallbackController

  plug Astarte.Housekeeping.APIWeb.Plug.AuthorizePath

  def index(conn, _params) do
    realms = Realms.list_realms()
    render(conn, "index.json", realms: realms)
  end

  def create(conn, %{"data" => realm_params}) do
    with {:ok, %Realm{} = realm} <- Realms.create_realm(realm_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", realm_path(conn, :show, realm))
      |> render("show.json", realm: realm)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, %Realm{} = realm} <- Realms.get_realm(id) do
      render(conn, "show.json", realm: realm)
    end
  end

  def update(conn, %{"id" => id, "data" => realm_params}) do
    with {:ok, %Realm{} = realm} <- Realms.get_realm(id),
         {:ok, %Realm{} = realm} <- Realms.update_realm(realm, realm_params) do
      render(conn, "show.json", realm: realm)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Realm{} = realm} <- Realms.get_realm(id),
         {:ok, %Realm{}} <- Realms.delete_realm(realm) do
      send_resp(conn, :no_content, "")
    end
  end
end
