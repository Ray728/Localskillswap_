from django.urls import path
from .views import SkillListCreate, SkillDetail

urlpatterns = [
    path('skills/', SkillListCreate.as_view(), name='skill-list-create'),
    path('skills/<int:pk>/', SkillDetail.as_view(), name='skill-detail'),
]