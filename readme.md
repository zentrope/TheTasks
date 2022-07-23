# TheTasks

Another macOS app for managing tasks. This one is as minimalist as I can get. You add tasks, and they carry over from day to day until you finish them. No project management. The tasks persist via Core Data, and sync via iCloud.

I use this to export work tasks once a week for record keeping. Tasks won’t export unless you make them exportable.

Soon as I can install macOS 13 and iOS 16, I’ll port this to the new SwiftUI navigation system so I can make an iOS version.

**More thoughts:**

I kinda want this to be like a paper notebook in that you write down the things you want to do that day, then cross them off. If something didn’t get done, you turn the page, then re-write the undone task on the new day. If you have too many of these kinds of carry-over tasks, put them in your project manager, reminders app, issue tracker, something like that.

So, you get a single list of all the available tasks, with the ability to filter by tags. You can show available tasks as well as the ones you accomplished today (everyone likes to see that they’re making process) or your can see every task.

This way of working helps me when I’m working in a kind of helpdesk mode, with lots of people asking for help on various things I might know about. Or just generally charting the things I’d like to complete that day.

This does _not_ help with tracking overall project completion. Most of what I do is ongoing. Keeping the turbines spinning, cleaning up messes, nursemaiding semi-automated processes, recalling old lore that might help out, etc. So, that’s what this app does.

And I’m using to try out a few things with SwiftUI and to figure out how to get things done (like editing tasks for a tag) that aren’t so easy in SwiftUI (or even AppKit). What’s the best UI I can come up with, given limitations?

##

## License

Copyright (c) 2022-present Keith Irwin

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see
[http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).
