package com.bytex.bytex.service;

import com.bytex.bytex.model.User;
import com.bytex.bytex.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * Registers a new user. For signup, the role is hardcoded to "Customer".
     * @param user The user object to be saved.
     * @return The saved user.
     */
    public User registerUser(User user) {
        // Ensure all new sign-ups are customers
        user.setRole("Customer");
        return userRepository.save(user);
    }

    /**
     * Authenticates a user based on username and password.
     * @param username The user's username.
     * @param password The user's password.
     * @return An Optional containing the user if authentication is successful, otherwise empty.
     */
    public Optional<User> loginUser(String username, String password) {
        Optional<User> optionalUser = userRepository.findByUsername(username);
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            // NOTE: Plain text password comparison as requested.
            // In a real-world application, you MUST use password hashing.
            if (password.equals(user.getPassword())) {
                return Optional.of(user);
            }
        }
        return Optional.empty();
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }
}
