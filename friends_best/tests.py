from django.test import TestCase
from rest_framework.test import APITestCase
from rest_framework.test import APIRequestFactory
from rest_framework import status

from .services import *
from .views import QueryViewSet


# Create your tests here.
class POSTQueryTest(APITestCase):
    def test_create_query(self):
        """
        Ensure we can create a new account object.
        """
        user_url = 'api/user'
        data = {}
        url = 'query/'
        data = {"user": "1","tags": ["work", "you", "POS"]}
        response = self.client.post(url, data, format='json')

        factory = APIRequestFactory()
        view = QueryViewSet.as_view({'post': 'create'})
        request = factory.get('/api/query/1')
        view_response = view(request, pk='1')
        view_response.render()  # Cannot access `response.content` without this.

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Query.objects.count(), 1)
        self.assertEqual(Query.objects.get().name, 'DabApps')
        self.assertEqual(view_response.content, '{"username": "lauren", "id": 4}')


class CreateFriendshipTest(TestCase):
    def setUp(self):
        u1 = createUser("Amy Adams")
        u2 = createUser("Bilbo Baggins")
        createFriendship(u1, u2)

    def test1(self):
        count = Friendship.objects.count()
        self.assertEqual(count, 2)
        f1 = Friendship.objects.get(id=1)
        f2 = Friendship.objects.get(id=2)
        f1u1 = f1.userOne.userName
        f1u2 = f1.userTwo.userName
        self.assertEqual(f1u1, "Amy Adams")
        self.assertEqual(f1u2, "Bilbo Baggins")
        f2u1 = f2.userOne.userName
        f2u2 = f2.userTwo.userName
        self.assertEqual(f2u1, "Bilbo Baggins")
        self.assertEqual(f2u2, "Amy Adams")


class SubmitQueryTest(TestCase):
    def setUp(self):
        u1 = createUser("Amy Adams")
        tags = ["healthy", "dog", "food"]
        submitQuery(u1, *tags)

    def test1(self):
        count = Query.objects.count()
        self.assertEqual(count, 1)
        q1 = Query.objects.get(id=1)
        u1 = q1.user.userName
        self.assertEqual(u1, "Amy Adams")
        count = QueryTag.objects.count()
        self.assertEqual(count, 3)
        t1 = QueryTag.objects.get(id=1)
        t2 = QueryTag.objects.get(id=2)
        t3 = QueryTag.objects.get(id=3)
        self.assertEqual(t1.query, q1)
        self.assertEqual(t2.query, q1)
        self.assertEqual(t3.query, q1)
        self.assertEqual(t1.tag, "healthy")
        self.assertEqual(t2.tag, "dog")
        self.assertEqual(t3.tag, "food")


class GetQueryHistoryTest(TestCase):
    def setUp(self):
        u1 = createUser("Amy Adams")
        u2 = createUser("Bilbo Baggins")
        t1 = ["coffee", "shop"]
        t2 = ["yoga", "mat"]
        t3 = ["baseball", "bat"]
        t4 = ["romance", "novel"]
        t5 = ["patio", "furniture"]
        submitQuery(u1, *t1)
        submitQuery(u1, *t2)
        submitQuery(u2, *t3)
        submitQuery(u2, *t4)
        submitQuery(u2, *t5)

    def test1(self):
        u1Querys = getQueryHistory(1)
        count = u1Querys.count()
        self.assertEqual(count, 2)
        q1 = u1Querys[0]
        q2 = u1Querys[1]
        self.assertEqual(q1.user.userName, "Amy Adams")
        self.assertEqual(q2.user.userName, "Amy Adams")


class CreateRecommendationTest(TestCase):
    def setUp(self):
        description = "solid gold car"
        createTextThing(description)
        u1 = createUser("Amy Adams")
        comments = "best car ever"
        tags = ["shiny", "gold", "car"]
        createRecommendation(u1, description, comments, *tags)
        u2 = createUser("Bilbo Baggins")
        comments = "better than pipe weed"
        tags = ["shiny", "magical", "travel", "machine"]
        createRecommendation(u2, description, comments, *tags)

    def test1(self):
        # recommendations were for the same thing,
        # so there should only have been one thing created
        count = TextThing.objects.count()
        self.assertEqual(count, 1)
        count = Thing.objects.count()
        self.assertEqual(count, 1)
        rec1 = Recommendation.objects.get(id=1)
        rec2 = Recommendation.objects.get(id=2)
        tags1 = RecommendationTag.objects.filter(recommendation=rec1)
        tags2 = RecommendationTag.objects.filter(recommendation=rec2)
        self.assertEqual(rec1.user.userName, "Amy Adams")
        self.assertEqual(rec2.user.userName, "Bilbo Baggins")
        self.assertEqual(rec1.comments, "best car ever")
        self.assertEqual(rec2.comments, "better than pipe weed")
        self.assertEqual(tags1.count(), 3)
        self.assertEqual(tags2.count(), 4)
        self.assertEqual(tags1[0].tag, "shiny")
        self.assertEqual(tags1[1].tag, "gold")
        self.assertEqual(tags1[2].tag, "car")
        self.assertEqual(tags2[0].tag, "shiny")
        self.assertEqual(tags2[1].tag, "magical")
        self.assertEqual(tags2[2].tag, "travel")
        self.assertEqual(tags2[3].tag, "machine")


class GetQuerySolutionsTest(TestCase):
    def setUp(self):
        # create things
        description1 = "solid gold car"
        createTextThing(description1)
        description2 = "shiny pocketwatch"
        createTextThing(description2)
        # create recommendations
        u1 = createUser("Amy Adams")
        comments = "best car ever"
        tags = ["shiny", "gold", "car"]
        createRecommendation(u1, description1, comments, *tags)
        u2 = createUser("Bilbo Baggins")
        comments = "better than pipe weed"
        tags = ["shiny", "magical", "travel", "machine"]
        createRecommendation(u2, description1, comments, *tags)
        comments = "a marvelous watch"
        tags = ["shiny", "watch"]
        createRecommendation(u2, description2, comments, *tags)
        # create query
        u3 = createUser("Cindy Crawford")
        qTags = ["shiny"]
        submitQuery(u3, *qTags)

    def test1(self):
        self.assertEqual(RecommendationTag.objects.count(), 9)
        s = getQuerySolutions(1)
        self.assertEqual(len(s), 2)
        s1 = s[0]
        self.assertEqual(s1.description, "solid gold car")
        c1 = s1.userComments
        self.assertEqual(len(c1.keys()), 2)
        self.assertEqual(c1["Amy Adams"], "best car ever")
        self.assertEqual(c1["Bilbo Baggins"], "better than pipe weed")
        s2 = s[1]
        self.assertEqual(s2.description, "shiny pocketwatch")
        c2 = s2.userComments
        self.assertEqual(len(c2.keys()), 1)
        self.assertEqual(c2["Bilbo Baggins"], "a marvelous watch")


# make sure the method returns  all solutions
class GetQuerySolutionsTest2(TestCase):
    def setUp(self):
        # create things
        description1 = "1 cool thing"
        description2 = "2 cool thing"
        description3 = "3 cool thing"
        description4 = "4 cool thing"
        description5 = "5 cool thing"
        description6 = "6 cool thing"
        description7 = "7 cool thing"
        description8 = "8 cool thing"
        description9 = "9 cool thing"
        description10 = "10 cool thing"
        description11 = "11 cool thing"
        description12 = "12 cool thing"
        description13 = "13 cool thing"
        description14 = "14 cool thing"
        description15 = "15 cool thing"
        createTextThing(description1)
        createTextThing(description2)
        createTextThing(description3)
        createTextThing(description4)
        createTextThing(description5)
        createTextThing(description6)
        createTextThing(description7)
        createTextThing(description8)
        createTextThing(description9)
        createTextThing(description10)
        createTextThing(description11)
        createTextThing(description12)
        createTextThing(description13)
        createTextThing(description14)
        createTextThing(description15)
        # create recommendations
        u1 = createUser("Amy Adams")
        u2 = createUser("Bob Barker")
        u3 = createUser("Cindy Crawford")
        u4 = createUser("Donald Dock")
        u5 = createUser("Eve Evans")
        comments = "whatever"
        tags = ["totally", "cool", "thing"]
        createRecommendation(u1, description1, comments, *tags)
        createRecommendation(u2, description2, comments, *tags)
        createRecommendation(u3, description3, comments, *tags)
        createRecommendation(u4, description4, comments, *tags)
        createRecommendation(u5, description5, comments, *tags)
        createRecommendation(u1, description6, comments, *tags)
        createRecommendation(u2, description7, comments, *tags)
        createRecommendation(u3, description8, comments, *tags)
        createRecommendation(u4, description9, comments, *tags)
        createRecommendation(u5, description10, comments, *tags)
        createRecommendation(u1, description11, comments, *tags)
        createRecommendation(u2, description12, comments, *tags)
        createRecommendation(u3, description13, comments, *tags)
        createRecommendation(u4, description14, comments, *tags)
        createRecommendation(u5, description15, comments, *tags)
        # create query
        u6 = createUser("Fred Foley")
        qTags = ["cool"]
        submitQuery(u6, *qTags)

    def test1(self):
        self.assertEqual(User.objects.count(), 6)
        self.assertEqual(Thing.objects.count(), 15)
        self.assertEqual(TextThing.objects.count(), 15)
        self.assertEqual(RecommendationTag.objects.count(), 45)
        s = getQuerySolutions(1)
        self.assertEqual(len(s), 15)


class GetRecommendationTagCountTest(TestCase):
    def setUp(self):
        u1 = createUser("Amy Adams")
        comments = "whatever"
        tags = ["a", "b", "c"]
        createRecommendation(u1, "apple", comments, *tags)
        tags = ["d", "e", "f"]
        createRecommendation(u1, "apple", comments, *tags)
        tags = ["a", "f", "g"]
        createRecommendation(u1, "orange", comments, *tags)
        tags = ["b", "b", "c"]
        createRecommendation(u1, "banana", comments, *tags)

    def test1(self):
        tc = getRecommendationTagCounts()
        self.assertEqual(len(tc.keys()), 7)
        self.assertEqual(tc["a"], 2)
        self.assertEqual(tc["b"], 3)
        self.assertEqual(tc["c"], 2)
        self.assertEqual(tc["d"], 1)
        self.assertEqual(tc["e"], 1)
        self.assertEqual(tc["f"], 2)
        self.assertEqual(tc["g"], 1)
        



