defmodule SleekFlowTodoWeb.Router do
  use SleekFlowTodoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SleekFlowTodoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  scope "/api", SleekFlowTodoWeb do
    pipe_through :api

    resources "/todos", TodoController, only: [:index, :create, :show, :update, :delete]
    get "/activities", ActivityFeedController, :index
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :sleekflow_todo, swagger_file: "swagger.json"
  end

  # Add swagger_info function
  def swagger_info do
    %{
      basePath: "/api",
      info: %{
        version: "1.0.0",
        title: "SleekFlow Todo API"
      },
      consumes: ["application/json"],
      produces: ["application/json"],
      tags: [
        %{name: "Todos", description: "Operations related to Todos"},
        %{name: "Activities", description: "Operations related to Activity Feed"}
      ]
    }
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:sleekflow_todo, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SleekFlowTodoWeb.Telemetry
    end
  end
end
