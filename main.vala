
namespace Qwant {
    public class Qwant {

        protected int results_count = 10;
        
        public Qwant () {
        }

        public void searchWeb (string query) {
            uint8[] message;
            string etags_out;

            string url = "http://api.qwant.com/search/web?q=%s&count=%u".printf(query, this.results_count);

            try {
                File file = File.new_for_commandline_arg (url);
                file.load_contents (null, out message, out etags_out);

                stdout.printf ("%s\n", (string)message);

                var parser = new Json.Parser ();
                parser.load_from_data ((string)message);

                var root_object = parser.get_root ().get_object ();
                var data = root_object.get_object_member ("data");
                var results = data.get_object_member ("result");
                var items = results.get_array_member ("items");
                var total = results.get_int_member ("total");
                var count = items.get_length ();

                stdout.printf ("%u of %u results\n\n", (uint)count, (uint)total);

                string[] urls;
                foreach (var item in items.get_elements ()) {
                    var result = item.get_object ();
                    stdout.printf ("[%u]:\t%s\n\t%s\n\t%s\n\n", 
                        (uint)result.get_int_member ("position"),
                        result.get_string_member ("title"),
                        result.get_string_member ("desc"),
                        result.get_string_member ("url")
                    );
                    urls.push (result.get_string_member ("url"));
                }

                int a = stdin.getc ();
                stdout.printf ("\n\nYou typed %c (%d)\n\n", a, a);


            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
        }

        public static int main (string[] args) {
            var qwant = new Qwant ();

            if (args.length != 2) {
                stderr.printf ("Usage: %s file\n", args[0]);
                return 1;
            }

            qwant.searchWeb (args[1]);
            return 0;
        }
    }
}
