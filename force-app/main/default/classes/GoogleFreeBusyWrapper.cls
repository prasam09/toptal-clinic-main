public  class GoogleFreeBusyWrapper {
        public String kind {get;set;} 
        public String timeMin {get;set;} 
        public String timeMax {get;set;} 
        public Calendars calendars {get;set;} 
        
        public class Busy {
            public String start {get;set;} 
            public String end_x {get;set;} // in json: end
        }
        
        public class Primary {
            public List<Busy> busy {get;set;} 
        }
        
        public class Calendars {
            public Primary primary {get;set;} 
        }
}