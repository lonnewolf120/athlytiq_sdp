know that the whole main backend is here along with the database connection url (the database is supabase)

Now,
This is the workflow I want for the Workout plan generation and exercise selection, apart from the current Generate workout, for the manual addition I want this workflow:

1 ) This is the WorkoutScreen where all the workouts are listed, both fetched locally and when connected to the internet and when the user is logged in the workouts will be fetched from the database, I want a Floating Action button on this screen to add workouts, import from backend or generate from AI

c:\Users\iftek\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\TempState\3047EE053D45323E65192012176A2A1C\WhatsApp Image 2025-09-05 at 23.02.02_08a67f3d.jpg


2) the screen after clicking the Add new workout:  
c:\Users\iftek\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\TempState\CC0E1713AA0E2BCBA6F5EDF1436B81EF\WhatsApp Image 2025-09-05 at 23.02.01_05eb9f01.jpg

3) After clicking add new exercises, All the exercises will be fetched from the backend, it'll also be synced and stored in the local database (sqflite) (if users dont have internet connection), they can Dynamically search the workouts and filter based on the workout name, target muscles, exercise developed by, equipments etc, (we may need to update the backend and database for it as well as add the necessary screens, API connection in the frontend), then users can select multiple such workouts:
c:\Users\iftek\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\TempState\A91E54CAF4AE7DCF7A1F13640FA21079\WhatsApp Image 2025-09-05 at 23.02.01_8f896990.jpg

4) This screen will come After selection of the workouts and the users can set the sets and reps for those workouts and save as well (which will be saved in local database first and then also sync with backend if internet connection is there and if no connection then we'll sync later, whenever the user logs in, we need to sync too)
c:\Users\iftek\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\TempState\96337D2CB0F87A553196FD9EC2CC66A8\WhatsApp Image 2025-09-05 at 23.02.01_85138d15.jpg

5) In the exercise selection menu when the user clicks on the exercise, they'll be shown in a Tab of 'Details' :
detailed view of that exercise, with video tutorial, workout details equipments, targetted muscles, preparation, workout description, etc
Tab of Suggestions:
 tips, tricks, personal notes, things suggested by experts and community members or friends for that workout etc
Tab of Records:
showing the users personal PR, all the user workout session details with sets, reps, weights, how many times they did that etc
c:\Users\iftek\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\TempState\F2A13EEAE490EF805070086405E26087\WhatsApp Image 2025-09-05 at 23.02.00_c6e44f8a.jpg

c:\Users\iftek\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\TempState\38840678620308EADD98D8632DF3D6D4\WhatsApp Image 2025-09-05 at 23.02.00_2f4b7390.jpg

c:\Users\iftek\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm\TempState\55053683268957697AA39FBA6F231C68\WhatsApp Image 2025-09-05 at 23.01.59_35cd0b00.jpg