## Working with RESTful APIs

First, create a new fork of the GitHub project located here: https://github.com/brandevnull/MyRestApp.

Then git clone it locally and open in Xcode.

### Exercise #1 - Getting oriented:

OK, so the first thing we are going to do is get oriented to the project.

What do you see? Let's keep this high-level. I don't want to talk about lines of code. Maybe a few things about VCs and other objects. How is the code organized? What do you think is going on?

### Exercise #2 - What API?:

The documentation for our API lives here: https://github.com/brandevnull/ios-api-demo

Let's make sense of this together.

### Challenge #1 - Registering through the API

Let's do this as a group challenge. Take take turns figuring out WHAT the code should do next and HOW we should go about this. We will reference documentation and discuss at any point. 

At the end of this challenge, you should be able to register new users.

Commit your changes and push them to github. Would somebody like to do a pull request back to the original repo?

### Challenge #2 - Authenticating via an API

Find the Challenge #2 mark using the Xcode editor.

Your challenge is to work with a partner to implement the authentication/login method. Use the API docs to understand the server request you need to make. Use our Challenge #1 code as an example -- the code should have a lot in common.

Commit and push your solution.

Questions:
- What does ApiManager need to do once is has a server response?
- How do we check that the request actually worked and the server responded how we expected it to?
- Why isn't this code in a UIViewController?

### Challenge #3 - Getting a list as an authenticated user

Find the mark for this challenge in Xcode. Which API method looks right for this? What is different about this request? How similar to the other challenges do you expect the code to look?

By the end of this challenge, you should be able to create new users, log them in, and view all other users. How is this feeling? :)

Git commit and push!

### Challenge #N:

There are more things to do. Some are called out, some are not. This is a real code base with real problems and potential to improve. What do you want to work on, to dig into?

Consider sharing solutions with classmates so that more stuff gets done. Use GitHub to collaborate.

