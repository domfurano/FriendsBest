package app.friendsbest.net.model;


public abstract class Card {
    String _id;
    String _title;
    String _content;
    String _author;
    CardType _cardType;

    enum CardType {
        Prompt(0),
        Recommendation(1),
        Recognition(2),
        Anonymous(3);

        private int _type;
        CardType(int type){
            _type = type;
        }

        CardType getType(int i){
            switch (i) {
                case 0:
                    return Prompt;
                case 1:
                    return Recommendation;
                case 2:
                    return Recognition;
                default:
                    return Anonymous;
            }
        }
    }
}
