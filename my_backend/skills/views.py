from rest_framework import generics
from .models import Skill
from .serializers import SkillSerializer

# для списка и создания)
class SkillListCreate(generics.ListCreateAPIView):
    queryset = Skill.objects.all()
    serializer_class = SkillSerializer

# для удаления и просмотра одного навыка)
class SkillDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Skill.objects.all()
    serializer_class = SkillSerializer