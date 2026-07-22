from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.modules.users.models import User
from app.modules.users.schemas import UserCreate, UserLogin, UserOut, Token
from app.modules.users.services import AuthService
from app.shared.dependencies import get_current_user

router = APIRouter(prefix="/users", tags=["Users & Auth"])


@router.post("/register", response_model=UserOut, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    return await service.register_user(user_data)


@router.post("/login", response_model=Token)
async def login(login_data: UserLogin, db: AsyncSession = Depends(get_db)):
    service = AuthService(db)
    return await service.authenticate_user(login_data)


@router.get("/me", response_model=UserOut)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user