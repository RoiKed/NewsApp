# NewsApp

TipRanks iOS technical task
The goal of this short development task is to create a demo app that enables the user to:
a. Search news items based on a query phrase
b. Scroll through the result list
c. View news article detail
Below is a mockup of the requested design, please create your app as close as possible to the provided UI reference. Please submit your implementation in Kotlin via a git repo link.
Implementation Requirements / Guidelines:
1. User will be able to enter a search phrase. The search action should be performed when the user clicks on ‘search’ button in the keyboard or ‘search’ button.
2. Use the following endpoint to retrieve the list of news items for the search query:
https://www.tipranks.com/api/news/posts
Parameters:
o page={page:Int, starting at 1}
o per_page=20 [no need to change this]
o search={search_query:String}
3. Implement a paging mechanism to load the next pages as the user scrolls down.
4. Paging should end in one of two scenarios:
a. API returns a 404 response or
b. Last response has < 20 items
5. Display a loader while loading the next page of news articles.
6. Clicking on a news item should open an internal screen that will display the article using a WebView component.
7. Bonus: Insert “Promotion” bar after article #3, #13, #23, #33, etc. Clicking on “Go to Promotion” should open https://www.tipranks.com/ in device browser
8. Bonus: Footer list item – show loader while loading next page OR “end of list” when no more pages (remove loader in item [5] if implemented)
Final Tip: Implement iOS best-practice architecture where possible, emphasis on MVVM
