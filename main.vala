
namespace Qwant {

    public class Qwant {

        protected int results_count = 10;

        protected Array<Result> results;


        public Qwant () {
            this.results = new Array<Result> ();
        }

        public void searchWeb (string query) {

            string locale = "de_de";
            string uri = "http://api.qwant.com/search/web?q=%s&count=%u&locale=%s".printf (
                Soup.URI.encode (query, null),
                this.results_count,
                locale
            );
            stdout.printf ("%s\n", uri);

            string body;
            uint8[] buf;
            File file = File.new_for_commandline_arg (uri);
            file.load_contents (null, out buf, null);
            body = (string)buf;

            /* var session = new Soup.Session (); */
            /* var message = new Soup.Message ("GET", uri); */
            /* session.send_message (message); */
            /* body = (string)message.response_body.flatten ().data; */

            /* message.response_headers.foreach ((name, val) => { */
            /*     stdout.printf ("%s = %s\n", name, val); */
            /* }); */


            try {
                var parser = new Json.Parser ();
                parser.load_from_data (body, -1);

                var root = parser.get_root ();
                if (root == null) {
                    stdout.printf ("Failed, no root!\n");
                    return;
                }
                var root_object = root.get_object ();

                var status = root_object.get_string_member ("status");
                if (status != "success") {
                    stdout.printf ("Failed. Status: %s, Code: %d", status, (int)root_object.get_int_member ("error"));
                    return;
                }

                var data = root_object.get_object_member ("data");
                var res = data.get_object_member ("result");
                var items = res.get_array_member ("items");
                var total = res.get_int_member ("total");
                var count = items.get_length ();

                stdout.printf ("%u of %u results\n\n", (uint)count, (uint)total);

                foreach (var item in items.get_elements ()) {
                    var r = item.get_object ();
                    var result = new Result(
                        r.get_string_member ("title"),
                        r.get_string_member ("desc"),
                        r.get_string_member ("source"),
                        r.get_string_member ("url"),
                        (uint)r.get_int_member ("position")
                    );
                    this.results.append_val (result);
                }

                for (int i = 0; i < results.length; i++) {
                    results.index(i).print ();
                }

                int a = stdin.getc ();
                string number = "%c".printf(a);
                int index = int.parse (number);

                Result result;
                if ((result = this.get_result_by_position (index)) != null) {
                    result.open ();
                }
            }
            catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
        }

        public Result? get_result_by_position (uint position) {
            for (int i = 0; i < results.length; i++) {
                Result result = results.index(i);
                if (result.position == position) {
                    return result;
                }
            }
            return null;
        }

        public static int main (string[] args) {
            var qwant = new Qwant ();

            if (args.length != 2) {
                stderr.printf ("Usage: %s query\n", args[0]);
                return 1;
            }

            qwant.searchWeb (args[1]);
            return 0;
        }
    }
}
