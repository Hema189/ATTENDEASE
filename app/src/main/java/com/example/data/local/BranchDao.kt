package com.example.data.local

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import com.example.data.model.Branch
import kotlinx.coroutines.flow.Flow

@Dao
interface BranchDao {
    @Query("SELECT * FROM branches WHERE active = 1 ORDER BY displayOrder ASC, code ASC")
    fun getAllActiveBranches(): Flow<List<Branch>>

    @Query("SELECT * FROM branches ORDER BY displayOrder ASC, code ASC")
    fun getAllBranches(): Flow<List<Branch>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBranch(branch: Branch)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBranches(branches: List<Branch>)

    @Update
    suspend fun updateBranch(branch: Branch)

    @Delete
    suspend fun deleteBranch(branch: Branch)

    @Query("SELECT COUNT(*) FROM branches")
    suspend fun countBranches(): Int
}
