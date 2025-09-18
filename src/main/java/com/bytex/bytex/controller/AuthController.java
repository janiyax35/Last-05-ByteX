package com.bytex.bytex.controller;

import com.bytex.bytex.model.User;
import com.bytex.bytex.service.UserService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Optional;

@Controller
public class AuthController {

    @Autowired
    private UserService userService;

    @GetMapping("/signup")
    public String showSignupForm(Model model) {
        model.addAttribute("user", new User());
        return "signup";
    }

    @PostMapping("/signup")
    public String processSignup(@ModelAttribute("user") User user, RedirectAttributes redirectAttributes) {
        // Check if username or email already exists
        if (userService.findByUsername(user.getUsername()).isPresent()) {
            redirectAttributes.addFlashAttribute("error", "Username already exists!");
            return "redirect:/signup";
        }
        if (userService.findByEmail(user.getEmail()).isPresent()) {
            redirectAttributes.addFlashAttribute("error", "Email already registered!");
            return "redirect:/signup";
        }

        userService.registerUser(user);
        redirectAttributes.addFlashAttribute("success", "Registration successful! Please log in.");
        return "redirect:/login";
    }

    @GetMapping("/login")
    public String showLoginForm(Model model) {
        return "login";
    }

    @PostMapping("/login")
    public String processLogin(@RequestParam String username, @RequestParam String password, HttpSession session, RedirectAttributes redirectAttributes) {
        Optional<User> authenticatedUser = userService.loginUser(username, password);

        if (authenticatedUser.isPresent()) {
            User user = authenticatedUser.get();
            session.setAttribute("user", user);

            // Redirect based on role
            switch (user.getRole()) {
                case "Admin":
                    return "redirect:/admin/dashboard";
                case "Staff":
                    return "redirect:/staff/dashboard";
                case "Technician":
                    return "redirect:/technician/dashboard";
                case "ProductManager":
                    return "redirect:/pm/dashboard";
                case "WarehouseManager":
                    return "redirect:/wm/dashboard";
                case "Customer":
                default:
                    return "redirect:/customer/dashboard";
            }
        } else {
            redirectAttributes.addFlashAttribute("error", "Invalid username or password.");
            return "redirect:/login";
        }
    }

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }

    // Placeholder Dashboards
    @GetMapping("/admin/dashboard")
    public String adminDashboard(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"Admin".equals(user.getRole())) return "redirect:/login";
        return "admin/dashboard";
    }

    @GetMapping("/staff/dashboard")
    public String staffDashboard(HttpSession session) {
         User user = (User) session.getAttribute("user");
        if (user == null || !"Staff".equals(user.getRole())) return "redirect:/login";
        return "staff/dashboard";
    }

    @GetMapping("/technician/dashboard")
    public String technicianDashboard(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"Technician".equals(user.getRole())) return "redirect:/login";
        return "technician/dashboard";
    }

    @GetMapping("/pm/dashboard")
    public String pmDashboard(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"ProductManager".equals(user.getRole())) return "redirect:/login";
        return "pm/dashboard";
    }

    @GetMapping("/wm/dashboard")
    public String wmDashboard(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"WarehouseManager".equals(user.getRole())) return "redirect:/login";
        return "wm/dashboard";
    }

    @GetMapping("/customer/dashboard")
    public String customerDashboard(HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"Customer".equals(user.getRole())) return "redirect:/login";
        return "customer/dashboard";
    }
}
