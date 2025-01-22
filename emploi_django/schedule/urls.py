from django.urls import path
from . import views

urlpatterns = [
    # Department and semester selection
    path('', views.department_selection, name='department_selection'),
    path('selection/', views.department_selection, name='selection'),
    path('get_semesters/<int:department_id>/', views.get_semesters, name='get_semesters'),
    
    # Department and semester-specific views (REQUIRED)
    path('schedule/<int:dept_id>/<int:semester_id>/', views.schedule_view, name='schedule_view'),
    path('plan/<int:dept_id>/<int:semester_id>/', views.plan_view, name='plan_view'),
    path('bilan/<int:dept_id>/<int:semester_id>/', views.bilan_view, name='bilan_view'),
    path('database/<int:dept_id>/<int:semester_id>/', views.database_view, name='database_view'),
    path('base/<int:dept_id>/<int:semester_id>/', views.base_view, name='base'),
   
    # Course-related views
    path('add_course/<int:dept_id>/<str:semester_id>/', views.add_course, name='add_course'),
    path('add_time_slot/<int:dept_id>/<int:semester_id>/', views.add_time_slot, name='add_time_slot'),
    
    # API endpoints
    path('api/courses/<int:dept_id>/<int:semester_id>/', views.get_courses, name='api_courses'),
    path('api/course/<str:code>/', views.get_course_info, name='api_course_info'),
    
    # Other existing endpoints
    path('api/plan/save/', views.save_plan, name='api_save_plan'),
    path('update_course/', views.update_course, name='update_course'),
    path('delete_course/', views.delete_course, name='delete_course'),
    path('api/update_bilan/', views.update_bilan, name='update_bilan'),
    path('api/professors/', views.get_professors, name='api_professors'),
    path('api/rooms/', views.get_rooms, name='api_rooms'),
    path('api/schedule/<int:week>/', views.get_schedule, name='api_schedule'),
    path('api/plan/all/', views.get_all_plan, name='api_plan_all'),
    path('api/plan/<int:week>/', views.get_plan, name='api_plan'),
    path('api/plan/<int:week>/', views.get_plan, name='get_plan'),
    path('api/plan/save/', views.save_plan, name='save_plan'),

    path('database/<int:dept_id>/<int:semester_id>/', views.database_view, name='database'),
    path('add_course/<int:dept_id>/<int:semester_id>/', views.add_course, name='add_course'),
]
