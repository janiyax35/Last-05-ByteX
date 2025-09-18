package com.bytex.bytex.repository;

import com.bytex.bytex.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    /**
     * Finds a user by their username.
     * @param username the username to search for.
     * @return an Optional containing the user if found, or empty otherwise.
     */
    Optional<User> findByUsername(String username);

    /**
     * Finds a user by their email.
     * @param email the email to search for.
     * @return an Optional containing the user if found, or empty otherwise.
     */
    Optional<User> findByEmail(String email);
}
