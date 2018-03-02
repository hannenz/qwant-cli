namespace Qwant {
    public class Result {

        public string title { get; set; }
        public string desc { get;  set; } 
        public string source { get; set; }
        public string url { get; set; }
        public uint position { get; set; }

        public Result (string title, string desc, string source, string url, uint position) {
            this.title = title;
            this.desc = desc;
            this.source = source;
            this.url = url;
            this.position = position;
        }

        public void print () {
            stdout.printf ("[%u]:\t%s\n\t%s\n\t%s\n\n", 
                (uint)this.position,
                this.title,
                this.desc,
                this.url
            );
            
        }
        public void open () {
            // xdg open url (dbus??)
            stdout.printf ("Opening: %u: %s\n", this.position, this.url);
        }
    }
}
