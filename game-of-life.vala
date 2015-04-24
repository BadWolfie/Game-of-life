using Gtk;

/**
 * @brief [brief description]
 *
 * @author Ian Hernández <ihernandezs@openmailbox.org>
 */
public class GameOfLife : Gtk.Application {
	private GOLWindow ventana;

	private const GLib.ActionEntry[] app_entries = {
		{ "graphic", graphic_cb, null, null, null },
        { "about", about_cb, null, null, null },
        { "quit", quit_cb, null, null, null },
    };

	public GameOfLife() {
		Object(application_id: "badwolfie.game-of-life.app",
			flags: ApplicationFlags.NON_UNIQUE);
	}

	protected override void startup() {
		base.startup();

		add_action_entries(app_entries,this);
		ventana = new GOLWindow(this);

		var builder = new Gtk.Builder();
		try {
			builder.add_from_file("menus.ui");
		} catch (Error e) {
			error("Error al cargar menu UI: %s", e.message);
		}

		var appmenu = builder.get_object("appmenu") as MenuModel;
		set_app_menu(appmenu);
	}

	protected override void activate() {
		base.activate();
		ventana.present();
		Posix.system("clear");
	}

	protected override void shutdown() {
		base.shutdown();
	}
	
	private void graphic_cb() {
		ventana.dialog.show_all();
	}

	private void about_cb() {
		string[] authors = { "Ian Hernández <ihernandezs@openmailbox.org>" };

        string[] documenters = { "Ian Hernández" };

        string comments = "Implementación en Vala y GTK+ del\nautómata celular ";
        comments += "\"Game of Life\".";

        string license = null;
        try {
        	FileUtils.get_contents("./LICENSE_HEADER", out license);
        } catch (Error e) {
        	stderr.printf("Error: %s\n", e.message);
        }

        Gtk.show_about_dialog(ventana,
			"program-name", ("Game of Life"),
			"title","Acerca de Game of Life",
			"copyright", ("Copyright \xc2\xa9 2015 Ian Hernández"),
			"comments",(comments),
			"website","https://github.com/BadWolfie/Game-of-life",
			"website_label","Página web",
			"license",license,
			"logo-icon-name", "chrome-app-list",
			"documenters", documenters,
			"authors", authors,
			"version", "1.2.0"
		);
	}

	private void quit_cb() {
		ventana.destroy();
	}

	public static int main(string[] args) {
		if (!Thread.supported()) {
			stderr.printf("No se tiene soporte para hilos.");
			return -1;
		}

		Gtk.Window.set_default_icon_name ("chrome-app-list");
		var app = new GameOfLife();
		return app.run(args);
	}
}
